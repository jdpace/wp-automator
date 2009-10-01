set :application, "wordpress.enventys.com"
set :repository,  "git://github.com/jdpace/wp-automator.git"
set :deploy_to,   "/var/www/#{application}"

set :scm, :git
set :branch, "master"
set :user, "www"
set :deploy_via, :remote_cache

default_run_options[:pty] = true
ssh_options[:port] = 52000
ssh_options[:forward_agent] = true

#load 'capistrano/ext/rails-database-migrations.rb'
#load 'capistrano/ext/rails-shared-directories.rb'
#load 'capistrano/ext/passenger-mod-rails.rb'  # Restart task for use with mod_rails
#load 'capistrano/ext/web-disable-enable.rb'   # Gives you web:disable and web:enable

role :web, "wordpress.enventys.com"
role :app, "wordpress.enventys.com"
role :db,  "wordpress.enventys.com", :primary => true

desc "Symlinks the database.yml into the current release"
task :after_update_code, :except => {:no_release => true} do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
end

namespace :mod_rails do
  desc <<-DESC
  Restart the application altering tmp/restart.txt for mod_rails.
  DESC
  task :restart, :roles => :app do
    run "touch  #{release_path}/tmp/restart.txt"
  end
end

namespace :deploy do
  %w(start restart).each do |name| 
    task name, :roles => :app do mod_rails.restart end
  end
end