#!/usr/bin/env ruby
# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require 'rubygems'
require 'pathname'

class Rails
  def self.root
    @@root ||= Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), "..")))
  end

  def self.env
    env = 'development'
    env = ENV['RAILS_ENV'] if ENV.has_key?('RAILS_ENV')
    env = ARGV[1] if ARGV.length == 2
    env.downcase
  end
end

if ARGV.length >= 1
  setting_name = ARGV[0]
  if Rails.env == 'script_server' # load from the special script_server_config.yml file
    require 'yaml'
    script_server_config_file = Rails.root.join('config', 'script_server.yml')
    begin
      print YAML.load_file(script_server_config_file)['script_server'][setting_name]
    rescue
      $stderr.puts "Setting '#{setting_name}' not found in file #{script_server_config_file}."
      $stderr.puts "Does that file exist? If not, copy it from #{File.basename(script_server_config_file)}.example in the same directory and run this script again."
      Process.exit(1)
    end
  else                            # load from the general diaspora settings file
    require 'active_support/core_ext/class/attribute_accessors'
    require 'active_support/core_ext/object/blank'
    require 'settingslogic'
    require Rails.root.join('app', 'models', 'app_config')
    setting_name = setting_name.to_sym
    if (!AppConfig.respond_to?(setting_name) || AppConfig.send(setting_name).nil?) && AppConfig[setting_name].nil?
      $stderr.puts "Could not find setting #{ARGV[0]} for environment #{Rails.env}."
      Process.exit(1)
    elsif AppConfig.respond_to?(setting_name)
      print AppConfig.send(setting_name)
    else
      print AppConfig[setting_name]
    end
  end
else
  $stderr.puts "Usage: ./script/get_config.rb option [section]"
  $stderr.puts ""
  $stderr.puts "section defaults to development"
  Process.exit(1)
end
