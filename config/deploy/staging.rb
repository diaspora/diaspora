set :config, config_yaml['staging']

set :deploy_to, config['deploy_to']
set :current_dir, config['current_dir']
set :rails_env, config['rails_env']
set :user, config['user']
if config['password']
  set :password, config['password']
end
if config['branch']
  set :branch, config['branch']
end
set :repository, config['repo']
server config['server'], :app, :web, :db, :primary => true
set :svc_sudo, (config['svc_sudo'] || false)
default_run_options[:pty] = true if svc_sudo

