#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

def load_config_yaml filename
  YAML.load(File.read(filename))
end

if File.exist? "#{Rails.root}/config/app_config.yml"
  all_envs = load_config_yaml "#{Rails.root}/config/app_config.yml"
  all_envs = load_config_yaml "#{Rails.root}/config/app_config_example.yml" unless all_envs
else
  puts "WARNING: No config/app_config.yml found! Look at config/app_config_example.yml for help."
  all_envs = load_config_yaml "#{Rails.root}/config/app_config_example.yml"
end

if all_envs[Rails.env.to_s]
  APP_CONFIG = all_envs['default'].merge(all_envs[Rails.env.to_s]).symbolize_keys
else
  APP_CONFIG = all_envs['default'].symbolize_keys
end

puts "WARNING: Please modify your app_config.yml to have a proper pod_url!" if APP_CONFIG[:pod_url] == "http://example.org/" && Rails.env != :test
