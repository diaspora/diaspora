#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

set :config_yaml, YAML.load_file(File.dirname(__FILE__) + '/deploy_config.yml')

require 'bundler/capistrano'
set :bundle_dir, ''

set :stages, ['production', 'staging']
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

set :application, 'diaspora'
set :scm, :git
set :use_sudo, false
set :scm_verbose, true
set :repository_cache, "remote_cache"
set :deploy_via, :checkout

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
    thins = capture "svstat /service/thin*"
    matches = thins.match(/(thin_\d+):/).captures

    matches.each_with_index do |thin, index|
      unless index == 0
        puts "sleeping for 20 seconds"
        sleep(20)
      end
      run "svc -t /service/#{thin}"
    end

    run "svc -t /service/resque_worker*"
  end

  task :kill do
    run "svc -k /service/thin*"
    run "svc -k /service/resque_worker*"
  end

  task :start do
    run "svc -u /service/thin*"
    run "svc -u /service/resque_worker*"
  end

  task :stop do
    run "svc -d /service/thin*"
    run "svc -d /service/resque_worker*"
  end
end

after "deploy:symlink", "deploy:symlink_config_files", "deploy:symlink_cookie_secret", "deploy:bundle_static_assets"
