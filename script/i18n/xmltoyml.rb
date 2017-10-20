#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.


require 'rubygems'
require 'yaml'
require 'fileutils'
require 'active_model'
require 'active_model/serializers/xml'

if ARGV.length == 0
  $stderr.puts "Usage: ./script/i18n/xmltoyml.rb locale"
  $stderr.puts ""
  $stderr.puts "Imports XML-style locales"
  $stderr.puts "It expects the XML files in xml_locales/"
  $stderr.puts "You can specify the locale to import via the first parameter"
  Process.exit(1)
else
  locale = ARGV[0]
end

unless File.exists?('xml_locales')
  $stderr.puts "xml_locales directory does not exist!"
  Process.exit(2)
end

data = { "config/locales/diaspora/#{locale}.yml" => "xml_locales/#{locale}.xml",
         "config/locales/devise/devise.#{locale}.yml" => "xml_locales/devise.#{locale}.xml",
         "config/locales/javascript/javascript.#{locale}.yml" => "xml_locales/javascript.#{locale}.xml" }

copyright = "#   Copyright (c) 2010-2011, Diaspora Inc.  This file is\n#   licensed under the Affero General Public License version 3 or later.  See\n#   the COPYRIGHT file.\n\n"

data.each do |destfile, sourcefile|
  if File.exists?(sourcefile)
    source = open(sourcefile)
    dest = open(destfile, 'w')
    dest.write Hash.from_xml(source)['hash'].to_yaml.gsub('---', copyright)
    dest.close
  else
    $stderr.puts "Warning: #{sourcefile} does not exist!"
  end
end
