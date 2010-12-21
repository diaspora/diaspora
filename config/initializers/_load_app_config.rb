#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
#   Sets up APP_CONFIG. Unless stated below, each entry is a the string in
#   the file app_config.yml, as applicable for current environment.
#
#   Specific items
#     * pod_url: As in app_config.yml, normalized with a trailing /.
#     * pod_uri: An uri object derived from pod_url.

require 'uri'

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

begin
    APP_CONFIG[:pod_uri] = URI.parse( APP_CONFIG[:pod_url])
rescue
    puts "WARNING: pod url " + APP_CONFIG[:pod_url] + " is not a legal URI"
end

APP_CONFIG[:pod_url] = APP_CONFIG[:pod_uri].normalize.to_s

if APP_CONFIG[:pod_uri].host == "example.org" && Rails.env != "test"
    puts "WARNING: Please modify your app_config.yml to have a proper pod_url!"
end
