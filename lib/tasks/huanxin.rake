require 'huanxin'
include Huanxin

namespace :huanxin do
  desc 'regist user in database for huanxin'
  task :regist_users_to_huanxin => :environment do
    #find_each for batch query
    User.find_each do |user|
      unless user.register_huanxin?
        register_user user
      end
    end
  end

  desc 'unregist user in database for huanxin'
  task :regist_users_to_huanxin => :environment do
    #find_each for batch query
    User.find_each do |user|
      if user.register_huanxin?
        unregister_user user
      end
    end
  end
end

