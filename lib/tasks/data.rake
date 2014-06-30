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

end