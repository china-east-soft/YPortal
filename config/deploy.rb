require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
#require 'mina/whenever'

environments = {
  'production' => {
    domain: '114.215.180.66',
    branch: 'master'
  }
}

rails_env = environments.keys.include?(ENV['RAILS_ENV']) ? ENV['RAILS_ENV'] : 'production'
branch = environments[rails_env][:branch]
domain = environments[rails_env][:domain]

set :rails_env, rails_env
set :domain, domain
set :deploy_to, "/var/app/portal"
set :repository, 'git@github.com:china-east-soft/YPortal.git'
set :branch, branch
set :ssh_options, '-A'

set :shared_paths, ['log', 'tmp/restart.txt', 'public/uploads', 'public/robots.txt', 'config/database.yml']

set :user, 'andersen'
set :term_mode, :nil

set :rvm_path, '/usr/local/rvm'

task :environment do
  invoke :'rvm:use[ruby-2.1.1@default]'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]

  queue! %[touch "#{deploy_to}/shared/tmp/restart.txt"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/restart.txt"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads"]

  queue! %[touch "#{deploy_to}/shared/public/robots.txt"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/robots.txt"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/shared/config/database.yml'."]
  
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
    end
  end
end