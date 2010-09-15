#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



config = YAML.load_file(File.dirname(__FILE__) + '/deploy_config.yml')
all = config['cross_server']

set :backers,  config['servers']['backer']
set :application, "diaspora"
set :deploy_to, all['deploy_to']
#set :runner, "diasporaroot"
#set :current_dir, ""
# Source code
set :scm, :git
set :user, all['user'] 
#set :user, ARGV[0]
set :password, all['password'] if all['password']
set :scm_verbose, true
set :repository, all['repo']
set :branch, all['branch']
set :repository_cache, "remote_cache"
set :deploy_via, :checkout
#ssh_options[:forward_agent] = true
#set :ssh_options, { :forward_agent => true }
#
set :rails_env, ENV['rails_env'] || ENV['RAILS_ENV'] || all['default_env']

role :pivots, config['servers']['pivots']['url']

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# Start Nginx
after "deploy:cold" do
  run("nginx")
end

namespace :deploy do

  task :symlink_images do
    run "mkdir -p #{shared_path}/uploads"
    run "ln -s -f #{shared_path}/uploads #{current_path}/public/uploads" 
  end
  
  task :symlink_bundle do
    run "mkdir -p #{shared_path}/bundle"
    run "ln -s -f #{shared_path}/bundle #{current_path}/vendor/bundle" 
  end

   task :start do
      start_mongo
      start_thin
	end
  
  task :start_mongo do
		run("mkdir -p -v #{current_path}/log/db/ ")
    run("mkdir -p -v #{shared_path}/db/")
		run("mongod  --fork --logpath #{current_path}/log/db/mongolog.txt --dbpath #{shared_path}/db/ " )
  end

  task :start_thin do
		run("mkdir -p -v #{current_path}/log/thin/ ")
		run("cd #{current_path} && bundle exec thin start -C config/thin.yml")
  end

  task :stop do
    stop_thin
    run("killall -s 2 mongod || true")
  end
 
  task :go_cold do
    stop
    run("killall nginx")
  end

  task :stop_thin do
    run("killall -s 2 ruby || true") 
    #run("cd #{current_path} && bundle exec thin stop -C config/thin.yml || true")
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    stop 
    start
  end

  task :bundle_gems do
    run "cd #{current_path} && bundle install"
  end
  
  task :reinstall_old_bundler do
    #run ("rm #{current_path}/Gemfile.lock || true")
    run 'gem list | cut -d" " -f1 | xargs gem uninstall -aIx || true '
    run "gem install bundler -v 0.9.26 || true"
  end
  
  task :update_bundler do
    run 'gem install bundler'
  end
  
  
  task :migrate do
  end
 end
  
namespace :cloud do
  task :reboot do
    run('reboot')
  end

  task :clear_bundle do

    run('cd && rm -r -f .bundle')
  end
end
namespace :db do
  
  task :purge, :roles => [:pivots] do
    run "cd #{current_path} && bundle exec rake db:purge --trace RAILS_ENV=#{rails_env}"
  end
  

  task :tom_seed, :roles => :tom do
    run "cd #{current_path} && bundle exec rake db:seed:tom --trace RAILS_ENV=#{rails_env}"
    run "curl -silent -u tom@tom.joindiaspora.com:evankorth http://tom.joindiaspora.com/zombiefriends"
    backers.each do |backer|
      run "curl -silent -u  #{backer['username']}@#{backer['username']}.joindiaspora.com:#{backer['username']}#{backer['pin']} http://#{backer['username']}.joindiaspora.com/zombiefriendaccept"
      #run "curl -silent -u  #{backer['username']}@#{backer['username']}.joindiaspora.com:#{backer['username']}#{backer['pin']} http://#{backer['username']}.joindiaspora.com/set_profile_photo"
    end

  end

  task :backer_seed, :roles => :backer do
    (0..10).each { |n|
      run "curl -silent http://localhost/set_backer_number?number=#{n}", :only => {:number => n}
    }
    run "cd #{current_path} && bundle exec rake db:seed:backer --trace RAILS_ENV=#{rails_env}"
  end
  
  task :reset do
    purge
  end


end

after "deploy:symlink", "deploy:symlink_images", "deploy:symlink_bundle"
