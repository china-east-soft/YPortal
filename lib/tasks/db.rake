namespace :db do
  desc "set default terminal_version to all terminal"
  task set_default_terminal_version: :environment do
    lastest_version = TerminalVersion.where(release: true).order('version desc').first
    Terminal.where(terminal_version_id: nil).update_all(terminal_version_id: lastest_version.id)
  end
end
