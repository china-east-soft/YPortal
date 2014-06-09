require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina_sidekiq/tasks'
require 'mina/whenever'

environments = {
  'develop' => {
    domain: 'portal.cloudchain.co',
    branch: 'develop'
  },
  'production' => {
    domain: 'portal.cloudchain.cn',
    branch: 'master'
  }
}

rails_env = environments.keys.include?(ENV['RAILS_ENV']) ? ENV['RAILS_ENV'] : 'develop'
branch = environments[rails_env][:branch]
domain = environments[rails_env][:domain]

set :rails_env, rails_env
set :domain, domain
set :deploy_to, "/var/app/#{domain}"
set :repository, 'git@github.com:china-east-soft/YPortal.git'
set :branch, branch
set :ssh_options, '-A'

set :shared_paths, ['log', '.private_key', 'tmp/restart.txt', 'public/system', 'public/uploads', 'public/robots.txt', 'config/database.yml', 'config/nginx.conf', 'config/config.yml']

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
    end
  end
end
