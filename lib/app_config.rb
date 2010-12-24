# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

class AppConfig

  cattr_accessor :config_vars

  def self.[](key)
    config_vars[key]
  end

  def self.[]=(key, value)
    config_vars[key] = value
  end

  def self.configure_for_environment(env)
    load_config_for_environment(env)
    generate_pod_uri
    normalize_pod_url
    check_pod_uri
  end

  def self.load_config_for_environment(env)
    if File.exist? "#{Rails.root}/config/app_config.yml"
      all_envs = load_config_yaml "#{Rails.root}/config/app_config.yml"
      all_envs = load_config_yaml "#{Rails.root}/config/app_config.yml.example" unless all_envs
    else
      puts "WARNING: No config/app_config.yml found! Look at config/app_config.yml.example for help."
      all_envs = load_config_yaml "#{Rails.root}/config/app_config.yml.example"
    end

    env = env.to_s
    if all_envs[env]
      self.config_vars = all_envs['default'].merge(all_envs[env]).symbolize_keys
    else
      self.config_vars = all_envs['default'].symbolize_keys
    end
  end

  def self.generate_pod_uri
    require 'uri'
    unless self.config_vars[:pod_url] =~ /^(https?:\/\/)/
      self.config_vars[:pod_url] = "http://#{self.config_vars[:pod_url]}"
    end
    begin
      self.config_vars[:pod_uri] = URI.parse(self.config_vars[:pod_url])
    rescue
      puts "WARNING: pod url " + self.config_vars[:pod_url] + " is not a legal URI"
    end
  end

  def self.normalize_pod_url
    self.config_vars[:pod_url] = self.config_vars[:pod_uri].normalize.to_s
  end

  def self.check_pod_uri
    if self.config_vars[:pod_uri].host == "example.org" && Rails.env != "test"
      puts "WARNING: Please modify your app_config.yml to have a proper pod_url!"
    end
  end

  def self.load_config_yaml filename
    YAML.load(File.read(filename))
  end
end