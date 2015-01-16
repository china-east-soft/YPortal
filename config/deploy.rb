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
    branch: 'develop'
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

#todo change commit this when deply
#testing should deploy the newest, production not.
#set this because the api for app will change and not compatible
if rails_env == 'production'
  set :commit, '6484d53b'
end

set :ssh_options, '-A'

set :shared_paths, ['log', '.private_key', 'tmp/restart.txt', 'public/system', 'public/uploads', 'public/robots.txt', 'public/guides', 'public/cities', 'config/database.yml', 'config/nginx.conf', 'config/config.yml', 'config/auth_message.yml', 'pids/sidekiq.pid']

set :user, 'root'
set :term_mode, :nil

set :rvm_path, '/usr/local/rvm/scripts/rvm'

task :environment do
  invoke :'rvm:use[ruby-2.1.2@default]'
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

  queue! %[mkdir "#{deploy_to}/shared/public/guides"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/guides"]

  queue! %[mkdir "#{deploy_to}/shared/public/cities"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/cities"]

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

  queue! %[mkdir "#{deploy_to}/shared/pids"]
  queue! %[chmod g+rx, u+rwx "#{deploy_to}/shared/pids"]
  queue! %[touch "#{deploy_to}/shared/pids/sidekiq.pid"]
  queue! %[chmod g+rw,u+rw,o+rw" #{deploy_to}/shared/pids/sidekiq.pid"]

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
      queue! %[chmod g+rw,u+rw,o+rw "#{deploy_to}/current/public/"]

      invoke :'whenever:update'
      queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
      # invoke :'sidekiq:restart'
      # god will reboot sidekiq, use restart will start two sidekiq process, don't known why
      invoke :'sidekiq:stop'

      # munal set this, or will slow deploy progress, impress other colleague
      #queue! "#{rake} data:default_portal_styles"
      # queue! "#{rake} data:set_default_terminal_version"
      #queue! "#{rake} data:terminals_without_version_set_to_latest"
      # queue! "cd #{deploy_to}/#{current_path}"
      # queue! "#{rake} db:seed"

    end
  end
end

desc "Restarts the passenger server."
task :restart do
  invoke :'passenger:restart'
end

namespace :passenger do
  task :restart do
    queue %{
      echo "-----> Restarting passenger"
      cd "#{deploy_to}/#{current_path}"
      echo "------> enter #{deploy_to}/#{current_path}"
    }
    queue %{ #{echo_cmd %[touch tmp/restart.txt]} }
  end
end
