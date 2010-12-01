# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

task :default => [:spec, :cucumber]

require 'rake/clean'
CLEAN.include %w(**/*.{log,pyc,rbc})
