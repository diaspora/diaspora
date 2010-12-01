require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

require File.join(File.dirname(__FILE__), 'lib', 'addressable', 'version')

PKG_DISPLAY_NAME   = 'Addressable'
PKG_NAME           = PKG_DISPLAY_NAME.downcase
PKG_VERSION        = Addressable::VERSION::STRING
PKG_FILE_NAME      = "#{PKG_NAME}-#{PKG_VERSION}"

RELEASE_NAME       = "REL #{PKG_VERSION}"

RUBY_FORGE_PROJECT = PKG_NAME
RUBY_FORGE_USER    = "sporkmonger"
RUBY_FORGE_PATH    = "/var/www/gforge-projects/#{RUBY_FORGE_PROJECT}"
RUBY_FORGE_URL     = "http://#{RUBY_FORGE_PROJECT}.rubyforge.org/"

PKG_SUMMARY        = "URI Implementation"
PKG_DESCRIPTION    = <<-TEXT
Addressable is a replacement for the URI implementation that is part of
Ruby's standard library. It more closely conforms to the relevant RFCs and
adds support for IRIs and URI templates.
TEXT

PKG_FILES = FileList[
    "lib/**/*", "spec/**/*", "vendor/**/*",
    "tasks/**/*", "website/**/*",
    "[A-Z]*", "Rakefile"
].exclude(/database\.yml/).exclude(/[_\.]git$/)

RCOV_ENABLED = (RUBY_PLATFORM != "java" && RUBY_VERSION =~ /^1\.8/)
task :default => "spec"

WINDOWS = (RUBY_PLATFORM =~ /mswin|win32|mingw|bccwin|cygwin/) rescue false
SUDO = WINDOWS ? '' : ('sudo' unless ENV['SUDOLESS'])

Dir['tasks/**/*.rake'].each { |rake| load rake }
