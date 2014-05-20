namespace :data do
  
  desc 'clear vtoken'
  task :clear_vtoken => :environment do
    AuthToken.destroy_all
  end
end