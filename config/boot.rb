#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'pathname'

# Set up gems listed in the Gemfile.
gemfile = Pathname.new(__FILE__).dirname.join('..').expand_path.join('Gemfile')
begin
  ENV['BUNDLE_GEMFILE'] = gemfile.to_s
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)
