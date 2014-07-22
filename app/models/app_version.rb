# encoding: utf-8

class AppVersion < ExternalTable

  has_many :terminal_app_versions
  has_many :terminal_versions, through: :terminal_app_versions
  has_many :downloads

  scope :release, where(release: true)

  VERSION_DISPLAY_NAMES = {
    "ymtv_ios" => 'iOS客户端',
    "ymtv_android" => 'Android客户端',
    "ymtv_windows" => 'Windows客户端'
  }

  def current_release?
    AppVersion.where(release: true, name: self.name).order('version desc').first.id == self.id
  rescue
    return false
  end

  def is_greater? another_appversion
    Version.compare(self.version, another_appversion.version) == 1
  end

  private

  class << self
    def latest_release_by_name(name)
      where(release: true, name: name).order('version desc').first
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

