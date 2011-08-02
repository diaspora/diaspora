lib_dir = File.expand_path(File.join(File.dirname(__FILE__), "lib"))
$:.unshift(lib_dir)
$:.uniq!

require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

require File.join(File.dirname(__FILE__), 'lib/uuidtools', 'version')

PKG_DISPLAY_NAME   = 'UUIDTools'
PKG_NAME           = PKG_DISPLAY_NAME.downcase
PKG_VERSION        = UUID::VERSION::STRING
PKG_FILE_NAME      = "#{PKG_NAME}-#{PKG_VERSION}"

RELEASE_NAME       = "REL #{PKG_VERSION}"

RUBY_FORGE_PROJECT = PKG_NAME
RUBY_FORGE_USER    = "sporkmonger"
RUBY_FORGE_PATH    = "/var/www/gforge-projects/#{RUBY_FORGE_PROJECT}"
RUBY_FORGE_URL     = "http://#{RUBY_FORGE_PROJECT}.rubyforge.org/"

PKG_SUMMARY        = "UUID generator"
PKG_DESCRIPTION    = <<-TEXT
A simple universally unique ID generation library.
TEXT

PKG_FILES = FileList[
    "lib/**/*", "spec/**/*", "vendor/**/*",
    "tasks/**/*", "website/**/*",
    "[A-Z]*", "Rakefile"
].exclude(/database\.yml/).exclude(/[_\.]git$/)

RCOV_ENABLED = (RUBY_PLATFORM != "java" && RUBY_VERSION =~ /^1\.8/)
if RCOV_ENABLED
  task :default => "spec:verify"
else
  task :default => "spec"
end

WINDOWS = (RUBY_PLATFORM =~ /mswin|win32|mingw|bccwin|cygwin/) rescue false
SUDO = WINDOWS ? '' : ('sudo' unless ENV['SUDOLESS'])

Dir['tasks/**/*.rake'].each { |rake| load rake }
