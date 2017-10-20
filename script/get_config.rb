#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

unless ARGV.length >= 1
  $stderr.puts "Usage: ./script/get_config.rb var=option | option [...]"
  Process.exit(1)
end

require 'rubygems'
require 'pathname'

require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/delegation'

module Rails
  def self.root
    @@root ||= Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), "..")))
  end

  def self.env
    env = 'development'
    env = ENV['RAILS_ENV'] if ENV.has_key?('RAILS_ENV')
    env.downcase
  end
end

require Rails.root.join("config/load_config")

ARGV.each do |arg|
  var, setting_name = arg.split("=")
  setting_name = var unless setting_name
  setting = AppConfig[setting_name]
  setting = setting.get if setting.respond_to?(:_proxy?)
  if var != setting_name
    puts "#{var}=#{setting}"
  else
    puts setting
  end
end
