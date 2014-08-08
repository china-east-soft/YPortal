# encoding: utf-8

class AppVersion < ActiveRecord::Base

  #commented  not use
  # has_many :terminal_app_versions
  # has_many :terminal_versions, through: :terminal_app_versions

  has_many :downloads

  before_save :update_asset_attributes

  scope :release, where(release: true)

  validates :name, :version, :branch, :presence => true
  validates :version, :uniqueness => {:scope => [:name, :branch]}

  mount_uploader :file, FileUploader

  VERSION_DISPLAY_NAMES = {
    "ymtv_ios" => 'iOS客户端',
    "ymtv_android" => 'Android客户端',
  }

  def upgrade_path
    unless self.upgrade_file and !self.upgrade_file_url.blank?
      self.file_url
    else
      self.upgrade_file_url
    end
  end

  def status
    self.release ? "已发布" : "未发布"
  end

  def link
    if self.itunes_url.present?
      self.itunes_url
    else
      if self.file_url
        "http://#{Rails.application.config.default_url_options[:host]}#{self.file_url}"
      end
    end
  end

  def icon
    "#{name}.png"
  end

  def current_release?
    AppVersion.where(release: true, name: self.name).order('version desc').first.id == self.id
  rescue
    return false
  end

  def is_greater? another_appversion
    Version.compare(self.version, another_appversion.version) == 1
  end

  private
  def update_asset_attributes
    if file.present? && file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
    end
  end

  class << self
    def latest_release_by_name(name, branch = 'public')
      where(release: true, name: name, branch: branch).order('version desc').first
    end

    def latest_release
      release = []
      where(release: true).group_by(&:name).each do |name, apps|
        release << apps.sort{|a, b| a.version <=> b.version}.last
      end
      release
    end
  end

end

