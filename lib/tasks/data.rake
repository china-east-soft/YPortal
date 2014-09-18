namespace :data do

  desc 'clear vtoken'
  task :clear_vtoken => :environment do
    AuthToken.destroy_all
  end

  task :clear_test_vtokens => :environment do
    AuthToken.where(status: AuthToken.statuses[:test]).where("created_at < ?", Date.today - 1).destroy_all
  end

  task :default_portal_styles => :environment do
    Merchant.all.each do |merchant|
      merchant.get_portal_style
    end
  end

  desc "set default terminal_version to all terminal"
  task set_default_terminal_version: :environment do
    lastest_version = TerminalVersion.where(release: true).order('version desc').first
    Terminal.where(terminal_version_id: nil).update_all(terminal_version_id: lastest_version.id)
  end


  desc 'set terminal to latest version'
  task :terminals_without_version_set_to_latest => :environment do
    latest_version = TerminalVersion.where(release: true).order("created_at desc").first
    if latest_version
      Terminal.where(terminal_version_id: nil).update_all(terminal_version_id: latest_version.id)
    end
  end


  desc "generate fixed five television programs"
  task :generate_programs => :environment do
    Program::CMMB_SID_GLOBAL_PROGRAMS.each do |sid, name|
      p = Program.new(channel: "CMMB-00-#{sid}-*", name: name)
      unless p.save
        puts p.errors.full_messages
      end
    end
  end


  #comment by kailaichao
  #connect to external database instead not copy
  #
  #get terminal version info from cloudchain.cn
  # task :get_terminal_version => :environment do
  #   database = "yundao_staging"
  #   host = "10.241.92.118"
  #   username = "postgres"
  #   password = "123456"

  #   conn_yundao = PG.connect(host: host, dbname: database, user: username, password: password)
  #   conn_yundao.exec( "SELECT * FROM terminal_versions" ) do |result|
  #     TerminalVersion.transaction do
  #       TerminalVersion.delete_all
  #       result.each do |row|
  #         id, name, version, size, logo, note, seq,
  #         file_size, support_versions, release, enforce,
  #         branch, created_at, updated_at = row.values_at('id', 'name', 'version', 'size',
  #                                                        'logo', 'note', 'seq', 'file_size',
  #                                                        'support_versions', 'release', 'enforce',
  #                                                        'branch', 'created_at', 'updated_at')

  #         TerminalVersion.create(id: id, name: name, version: version, size: size, logo: logo,
  #                                note: note, seq: seq, file_size: file_size,
  #                                support_versions: support_versions, release: release,
  #                                enforce: enforce, branch: branch, created_at: created_at,
  #                                updated_at: updated_at)
  #       end
  #     end
  #   end
  # end
end
