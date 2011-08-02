require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

task :build => :raise_if_psych_is_defined

task :raise_if_psych_is_defined do
  if defined?(Psych)
    raise <<-MSG
===============================================================================
Gems compiled in Ruby environments with Psych loaded are incompatible with Ruby
environments that don't have Psych loaded. Try building this gem in Ruby 1.8.7
instead.
===============================================================================
MSG
  end
end

require 'rake'
require 'fileutils'
require 'pathname'

task :clobber do
  rm_rf 'pkg'
end

task :default do
  puts "Nothing to do for the default task"
end

