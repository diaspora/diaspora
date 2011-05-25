# Copyright (c) 2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

class AppConfig

  cattr_accessor :config_vars
  cattr_accessor :base_file_path
  cattr_accessor :file_path
  
  def self.base_file_path
    @@base_file_path || File.join(Rails.root, "config", "app_base.yml")
  end
  
  def self.file_path
    @@file_path || File.join(Rails.root, "config", "app.yml")
  end
  
  def self.[](key)
    config_vars[key]
  end

  def self.[]=(key, value)
    config_vars[key] = value
  end

  def self.has_key?(key)
    config_vars.has_key?(key)
  end

  def self.configure_for_environment(env)
    load_config_for_environment(env)
    generate_pod_uri
    normalize_pod_url
    check_pod_uri
    downcase_usernames
  end

  def self.load_config_for_environment(env)
    if File.exist?(base_file_path)
      all_envs = load_config_yaml(base_file_path)
    else
      $stderr.puts "OH NO! Required file #{base_file_path} doesn't exist! Did you move it?"
      all_envs = {}
    end
    if File.exist?(file_path)
      all_envs_custom = load_config_yaml(file_path)
      all_envs.deep_merge!(all_envs_custom)
    elsif File.exist? "#{Rails.root}/config/app_config.yml"
      all_envs_custom = load_config_yaml "#{Rails.root}/config/app_config.yml"
      all_envs.deep_merge!(all_envs_custom)
      $stderr.puts "DEPRECATION WARNING: config/app_config.yml has been renamed to config/app.yml"
    else
      unless Rails.env == "development" || Rails.env == "test"
        $stderr.puts "WARNING: No config/app.yml found! Look at config/app.yml.example for help."
      end
    end

    # Is there a config at all?
    unless all_envs['default']
      $stderr.puts "What did you do? There's no config at all!"
      Process.exit(false)
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
      puts "WARNING: Please modify your app.yml to have a proper pod_url!"
    end
  end


  def self.downcase_usernames
    [:admins, :auth_tokenable].each do |key|
      self.config_vars[key] ||= []
      self.config_vars[key].collect! { |username| username.downcase }
    end
  end

  def self.load_config_yaml filename
      # nil values are bad for merges and have no meaning here, so lets get rid of them
    YAML.load(File.read(filename)).delete_if { |k, v| v.nil? }
  end
end
