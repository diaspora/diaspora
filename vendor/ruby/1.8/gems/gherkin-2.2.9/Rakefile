# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

require 'rake/clean'

$:.unshift(File.dirname(__FILE__) + '/lib')
require 'gherkin/version'

Dir['tasks/**/*.rake'].each { |rake| load File.expand_path(rake) }

task :default  => [:spec, :cucumber]
task :spec     => defined?(JRUBY_VERSION) ? :jar : :compile
task :cucumber => defined?(JRUBY_VERSION) ? :jar : :compile