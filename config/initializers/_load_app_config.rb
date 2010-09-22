#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

raw_config = File.read("#{Rails.root}/config/app_config.yml")
all_envs = YAML.load(raw_config)
 
unless all_envs
  raw_config = File.read("#{Rails.root}/config/app_config_example.yml")
  all_envs = YAML.load(raw_config)
end

if all_envs[Rails.env]
  APP_CONFIG = all_envs['default'].merge(all_envs[Rails.env]).symbolize_keys
else
  APP_CONFIG = all_envs['default'].symbolize_keys
end

puts "WARNING: Please modify your app_config.yml to have a proper pod_url!" if APP_CONFIG[:pod_url] == "http://example.org/" && Rails.env != :test
