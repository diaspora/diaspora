# Ferret DRb server Capistrano tasks
# 
# Usage:
# in your Capfile, add acts_as_ferret's recipes directory to your load path and
# load the ferret tasks:
#
# load_paths << 'vendor/plugins/acts_as_ferret/recipes'
# load 'aaf_recipes'
#
# This will hook aaf's DRb start/stop tasks into the standard
# deploy:{start|restart|stop} tasks so the server will be restarted along with
# the rest of your application.
# Also an index directory in the shared folder will be created and symlinked
# into current/ when you deploy.
#
# In order to use the ferret:index:rebuild task, declare the indexes you intend to
# rebuild remotely in config/deploy.rb:
#
# set :ferret_indexes, %w( model another_model shared )
#
# HINT: To be very sure that your DRb server and application are always using
# the same model and schema versions, and you never lose any index updates because
# of the DRb server being restarted in that moment, use the following sequence
# to update your application:
#
# cap deploy:stop deploy:update deploy:migrate deploy:start
#
# That will stop the DRb server after stopping your application, and bring it
# up before starting the application again. Plus they'll never use different
# versions of model classes (which might happen otherwise)
# Downside: Your downtime is a bit longer than with the usual deploy, so be sure to
# put up some maintenance page for the meantime. Obviously this won't work if
# your migrations need acts_as_ferret (i.e. if you update model instances which
# would lead to index updates). In this case bring up the DRb server before
# running your migrations:
#
# cap deploy:stop deploy:update ferret:start deploy:migrate ferret:stop deploy:start
#
# Chances are that you're still not safe if your migrations not only modify the index, 
# but also change the structure of your models. So just don't do both things in
# one go - I can't think of an easy way to handle this case automatically.
# Suggestions and patches are of course very welcome :-)

namespace :ferret do

  desc "Stop the Ferret DRb server"
  task :stop, :roles => :app do
    rails_env = fetch(:rails_env, 'production')
    ruby = fetch(:ruby, '/usr/bin/env ruby')
    run "cd #{current_path}; #{ruby} script/ferret_server -e #{rails_env} stop || true"
  end

  desc "Start the Ferret DRb server"
  task :start, :roles => :app do
    rails_env = fetch(:rails_env, 'production')
    ruby = fetch(:ruby, '/usr/bin/env ruby')
    run "cd #{current_path}; #{ruby} script/ferret_server -e #{rails_env} start"
  end

  desc "Restart the Ferret DRb server"
  task :restart, :roles => :app do
    top.ferret.stop
    sleep 1
    top.ferret.start
  end

  namespace :index do

    desc "Rebuild the Ferret index. See aaf_recipes.rb for instructions."
    task :rebuild, :roles => :app do
      rake = fetch(:rake, 'rake')
      rails_env = fetch(:rails_env, 'production')
      indexes = fetch(:ferret_indexes, [])
      if indexes.any?
        run "cd #{current_path}; RAILS_ENV=#{rails_env} INDEXES='#{indexes.join(' ')}' #{rake} ferret:rebuild"
      end
    end

    desc "purges all indexes for the current environment"
    task :purge, :roles => :app do
      run "rm -fr #{shared_path}/index/#{rails_env}"
    end

    desc "symlinks index folder"
    task :symlink, :roles => :app do
      run "mkdir -p  #{shared_path}/index && rm -rf #{release_path}/index && ln -nfs #{shared_path}/index #{release_path}/index"
    end

    desc "Clean up old index versions"
    task :cleanup, :roles => :app do
    	indexes = fetch(:ferret_indexes, [])
    	indexes.each do |index|
    	  ferret_index_path = "#{shared_path}/index/#{rails_env}/#{index}"
    	  releases = capture("ls -x #{ferret_index_path}").split.sort
    	  count = 2
    	  if count >= releases.length
    	    logger.important "no old indexes to clean up"
    	  else
    	    logger.info "keeping #{count} of #{releases.length} indexes"
    	    directories = (releases - releases.last(count)).map { |release|
    	      File.join(ferret_index_path, release) }.join(" ")
    	    sudo "rm -rf #{directories}"
    	  end
    	end
    end
  end

end

after  "deploy:stop",    "ferret:stop"
before "deploy:start",   "ferret:start"

before "deploy:restart", "ferret:stop"
after  "deploy:restart", "ferret:start"
after "deploy:symlink", "ferret:index:symlink"

