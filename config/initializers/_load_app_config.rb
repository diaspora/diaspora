#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

def load_config_yaml filename
  YAML.load(File.read(filename))
end

if File.exist? "#{Rails.root}/config/app_config.yml"
  all_envs = load_config_yaml "#{Rails.root}/config/app_config.yml"
  all_envs = load_config_yaml "#{Rails.root}/config/app_config.yml.example" unless all_envs
else
  puts "WARNING: No config/app_config.yml found! Look at config/app_config.yml.example for help."
  all_envs = load_config_yaml "#{Rails.root}/config/app_config.yml.example"
end

if all_envs[Rails.env.to_s]
  APP_CONFIG = all_envs['default'].merge(all_envs[Rails.env.to_s]).symbolize_keys
else
  APP_CONFIG = all_envs['default'].symbolize_keys
end

APP_CONFIG[:terse_pod_url] = APP_CONFIG[:pod_url].gsub(/(https?:|www\.)\/\//, '')
APP_CONFIG[:terse_pod_url].chop! if APP_CONFIG[:terse_pod_url][-1, 1] == '/'

puts "WARNING: Please modify your app_config.yml to have a proper pod_url!" if APP_CONFIG[:terse_pod_url] == "example.org" && Rails.env != :test
