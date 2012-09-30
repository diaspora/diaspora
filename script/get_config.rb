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
    require 'active_support/core_ext/module/delegation'
    require 'active_support/core_ext/module/method_names'
    require Rails.root.join("config/load_config")
    
    setting = AppConfig.send(setting_name)
    setting = setting.get if setting.is_a?(Configuration::Proxy)
    print setting
  end
else
  $stderr.puts "Usage: ./script/get_config.rb option [section]"
  $stderr.puts ""
  $stderr.puts "section defaults to development"
  Process.exit(1)
end
