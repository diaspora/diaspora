set :config, config_yaml['production']

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
