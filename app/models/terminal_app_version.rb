class TerminalAppVersion < ActiveRecord::Base

  belongs_to :terminal_version
  belongs_to :app_version

end

