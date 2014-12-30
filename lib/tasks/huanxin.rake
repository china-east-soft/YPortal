require 'huanxin'
include Huanxin

namespace :huanxin do
  desc '预先生成一千个无信息的用户， skip validate'
  task :generate_1k_users_without_info => :environment do
    generate_unused_users(1000)
  end

  desc "预先生成一万个无信息的用户"
  task :generate_10k_users_without_info => :environment do
    generate_unused_users(10000)
  end

  desc '向环信注册信息为空的用户'
  task :pre_regist_users => :environment do
    #find_each for batch query
    User.unused_users.find_each do |user|
      pre_register_user user
    end
  end

  desc '向环信注销无信息的用户'
  task :unregist_unused_users => :environment do
    #find_each for batch query
    User.unused_users.find_each do |user|
      if user.register_huanxin?
        unregister_user user
      end
    end
  end

  desc '删除无信息的用户，skip validate'
  task :generate_users_without_info => [:unregist_unused_users, :environment] do
    User.unused_users.find_each do |user|
      user.destroy unless user.register_huanxin?
    end
  end

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
  task :unregist_users_to_huanxin => :environment do
    #find_each for batch query
    User.find_each do |user|
      if user.register_huanxin?
        unregister_user user
      end
    end
  end

  def generate_unused_users(amount)
    amount.times do
      u = User.new
      u.save(validate: false)
    end
  end
end

