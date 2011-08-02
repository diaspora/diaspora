# encoding: utf-8
GHERKIN_VERSION = Gem::Specification.load(File.dirname(__FILE__) + '/gherkin.gemspec').version.version
require 'rubygems'
unless ENV['RUBY_CC_VERSION']
  require 'bundler'
  Bundler.setup
  Bundler::GemHelper.install_tasks
end
ENV['RUBYOPT'] = nil # Necessary to prevent Bundler from *&^%$#ing up rake-compiler.

require 'rake/clean'

begin
  # Support Rake >= 0.9.0
  require 'rake/dsl_definition'
  include Rake::DSL
rescue LoadError
end

$:.unshift(File.dirname(__FILE__) + '/lib')

Dir['tasks/**/*.rake'].each { |rake| load File.expand_path(rake) }

task :default  => [:spec, :cucumber]
task :spec     => defined?(JRUBY_VERSION) ? :jar : :compile
task :cucumber => defined?(JRUBY_VERSION) ? :jar : :compile