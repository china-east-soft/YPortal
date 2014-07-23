require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina_sidekiq/tasks'
require 'mina/whenever'

environments = {
  'develop' => {
    # domain: 'dev.cloudchain.co',
    domain: '114.215.180.66',
    branch: 'develop'
  },
  'production' => {
    domain: 'portal.cloudchain.cn',
    branch: 'master'
  },
  'testing' => {
    domain: 'portal.cloudchain.co',
    branch: 'master'
  }
}

rails_env = environments.keys.include?(ENV['RAILS_ENV']) ? ENV['RAILS_ENV'] : 'develop'
branch = environments[rails_env][:branch]
domain = environments[rails_env][:domain]

set :rails_env, rails_env
set :domain, domain

if rails_env == 'develop'
  set :deploy_to, "/var/app/dev.cloudchain.co"
else
  set :deploy_to, "/var/app/#{domain}"
end

set :repository, 'git@github.com:china-east-soft/YPortal.git'
set :branch, branch
set :ssh_options, '-A'

set :shared_paths, ['log', '.private_key', 'tmp/restart.txt', 'public/system', 'public/uploads', 'public/robots.txt', 'config/database.yml', 'config/nginx.conf', 'config/config.yml', 'config/auth_message.yml', 'pids/sidekiq.pid']

set :user, 'root'
set :term_mode, :nil

set :rvm_path, '/usr/local/rvm/scripts/rvm'

task :environment do
  invoke :'rvm:use[ruby-2.1.1@default]'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[touch -p "#{deploy_to}/shared/.private_key"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/.private_key"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]

  queue! %[touch "#{deploy_to}/shared/tmp/restart.txt"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/restart.txt"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir "#{deploy_to}/shared/public/system"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/system"]

  queue! %[mkdir "#{deploy_to}/shared/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads"]

  queue! %[touch "#{deploy_to}/shared/public/robots.txt"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/robots.txt"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/shared/config/database.yml'."]

  queue! %[touch "#{deploy_to}/shared/config/nginx.conf"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/shared/config/nginx.conf'."]

  queue! %[touch "#{deploy_to}/shared/config/config.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/shared/config/config.yml'."]

  queue! %[touch "#{deploy_to}/shared/config/auth_message.yml"]
  queue! %[chmod g+rw,u+rw,o+rw "#{deploy_to}/shared/config/auth_message.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/shared/config/auth_message.yml'."]

  queue! %[mkdir "#{deploy_to}/shared/pids]
  queue! %[chmod g+rx, u+rwx " #{deploy_to}/shared/pids"]
  queue! %[touch "#{deploy_to}/shared/pids/sidekiq.pid]
  queue! %[chmod g+rw,u+rw,o+rw "#{deploy_to}/shared/pid/sidekiq.pid"]

end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # stop accepting new workers
    invoke :'sidekiq:quiet'
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      invoke :'whenever:update'
      queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
      invoke :'sidekiq:restart'
      queue! "#{rake} data:default_portal_styles"

      queue! "cd #{deploy_to}/#{current_path}"
      queue! "#{rake} db:seed"
    end
  end
end
