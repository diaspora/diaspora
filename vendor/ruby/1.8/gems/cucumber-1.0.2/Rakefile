# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

$:.unshift(File.dirname(__FILE__) + '/lib')
Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

task :default => [:spec, :cucumber]

require 'rake/clean'
CLEAN.include %w(**/*.{log,pyc,rbc,tgz} doc)
