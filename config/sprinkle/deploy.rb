set :user, 'diasporaroot'
set :scm_passphrase, "evankorth311"

role :app, 'ps25770.dreamhost.com', :primary => true
# Source code
set :scm, :git
set :repository, "git://github.com:rsofaer/roxml.git"
set :branch, "master"
#set :repository_cache, "git_cache"
#set :deploy_via, :remote_cache
#set :ssh_options, { :forward_agent => true }

set :deploy_to, "/usr/local/diaspora"

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
  
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test"
  end
  
  task :lock, :roles => :app do
    run "cd #{current_release} && bundle lock;"
  end
  
  task :unlock, :roles => :app do
    run "cd #{current_release} && bundle unlock;"
  end
end

# HOOKS
after "deploy:update_code" do
  bundler.bundle_new_release
  # ...
end
