#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

config = YAML.load_file(File.dirname(__FILE__) + '/deploy_config.yml')
config = config['production']

set :rails_env, 'production'

set :application, 'diaspora'
set :deploy_to, config['deploy_to']
set :current_dir, config['current_dir']

set :scm, :git
set :user, config['user']
set :password, config['password']
set :use_sudo, false
set :scm_verbose, true
set :repository, config['repo']
set :repository_cache, "remote_cache"
set :deploy_via, :checkout

server config['server'], :app, :web, :db, :primary => true

namespace :deploy do
  task :symlink_config_files do
    run "ln -s -f #{shared_path}/config/database.yml #{current_path}/config/database.yml"
    run "ln -s -f #{shared_path}/config/app_config.yml #{current_path}/config/app_config.yml"
    run "ln -s -f #{shared_path}/config/oauth_keys.yml #{current_path}/config/oauth_keys.yml"
  end

  task :symlink_cookie_secret do
    run "ln -s -f #{shared_path}/config/initializers/secret_token.rb #{current_path}/config/initializers/secret_token.rb"
  end

  task :bundle_static_assets do
    run "cd #{current_path} && sass --update public/stylesheets/sass:public/stylesheets"
    run "cd #{current_path} && bundle exec jammit"
  end

  task :restart do
    run "killall ruby"
  end

  task :start do
    # daemontools FTW
  end

  task :stop do
    run "killall ruby"
  end
end

after "deploy:symlink", "deploy:symlink_config_files", "deploy:symlink_cookie_secret", "deploy:bundle_static_assets"