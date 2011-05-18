#!/usr/bin/env ruby
# Copyright (c) 2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require 'rubygems'
require 'yaml'

require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/deep_merge'

class Rails
  def self.root
    File.join(File.dirname(__FILE__), "..")
  end
  
  def self.env
    env = 'development'
    env = ENV['RAILS_ENV'] if ENV.has_key?('RAILS_ENV')
    env = ARGV[1] if ARGV.length == 2
    env.downcase
  end
end

require File.join(Rails.root, 'lib', 'app_config')


if ARGV.length >= 1
  key = ARGV[0].to_sym
  AppConfig.configure_for_environment(Rails.env)
  if AppConfig.has_key?(key)
    print AppConfig[key]
  else
    puts "Invalid option #{ARGV[0]}"
    exit 2
  end
else
  puts "Usage: ./script/get_config.rb option [section]"
  puts ""
  puts "section defaults to development"
  exit 1
end
