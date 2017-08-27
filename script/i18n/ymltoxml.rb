#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.
require 'rubygems'
require 'fileutils'
require 'yaml'
require 'active_model'
require 'active_model/serializers/xml'

if ARGV.length == 0
  $stderr.puts "Usage: ./script/i18n/ymltoxml.rb locale"
  $stderr.puts ""
  $stderr.puts "Exports locales to XML."
  $stderr.puts "You'll find the generated files in xml_locales/"
  $stderr.puts "You can specify the locale to export via the first parameter"
  Process.exit(1)
else
  locale = ARGV[0]
end

FileUtils.mkdir_p('xml_locales')

data = { "config/locales/diaspora/#{locale}.yml" => "xml_locales/#{locale}.xml",
         "config/locales/devise/devise.#{locale}.yml" => "xml_locales/devise.#{locale}.xml",
         "config/locales/javascript/javascript.#{locale}.yml" => "xml_locales/javascript.#{locale}.xml" }

data.each do |sourcefile, destfile|
  if File.exists?(sourcefile)
    source = YAML.load open(sourcefile)
    dest = open(destfile, 'w')
    dest.write source.to_xml
    dest.close
    puts "Generated #{destfile}"
  else
    $stderr.puts "Warning: #{sourcefile} does not exist!"
  end
end
