class TerminalVersion < ActiveRecord::Base

  has_many :termnials

  before_save :update_asset_attributes, :update_upgrade_note

  validates :name, :version, :branch, :presence => true

  validates :version, :uniqueness => {:scope => [:name, :branch]}

  scope :release, where(release: true)

  mount_uploader :file, FileUploader


  def display_name
    name
  end

  def status
    self.release ? "已发布" : "未发布"
  end

  def link
    "http://#{Rails.application.config.default_url_options[:host]}/#{self.file_url}"
  end

  def TerminalVersion.latest
    latest_version = nil
    TerminalVersion.where(release: true).each do |tv|
      latest_version = tv.version if (!latest_version || Version.compare(tv.version, latest_version) > 0)
    end
    latest_version
  end

  def current_release?
    TerminalVersion.where(release: true, name: self.name).order('version desc').first.try(:id) == self.id
  end

  def is_greater? another_terminalversion
    Version.compare(self.version, another_terminalversion.version) == 1
  end

  private
    def update_asset_attributes
      if file.present? && file_changed?
        self.content_type = file.file.content_type
        self.file_size = file.file.size
      end
    end

    def update_upgrade_note
      if warning.present? && !note.include?(warning)
        unless note =~ /\r\n|\r|\n$/
          note << "\r\n"
        end
        note << warning
      end
    end
end
