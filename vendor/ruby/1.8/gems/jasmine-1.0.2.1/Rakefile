$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/lib")
require "bundler"
Bundler.setup

def rspec2?
  Gem.available? "rspec", ">= 2.0"
end

def rails3?
  Gem.available? "rails", ">= 3.0"
end

if rspec2?
  require 'rspec'
  require 'rspec/core/rake_task'
else
  require 'spec'
  require 'spec/rake/spectask'
end
require 'ci/reporter/rake/rspec'

desc "Run all examples"
if rspec2?
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*.rb'
  end
else
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*.rb']
  end
end

task :spec => ['jasmine:copy_examples_to_gem', 'bundle_install', 'ci:setup:rspec']

task :spex do
  `bundle install`
  Rake::Task["spec"].invoke
end

task :default => :spec

namespace :jasmine do
  require './spec/jasmine_self_test_config'
  task :server do
    puts "your tests are here:"
    puts "  http://localhost:8888/"

    JasmineSelfTestConfig.new.start_server
  end

  desc "Copy examples from Jasmine JS to the gem"
  task :copy_examples_to_gem do
    unless File.exist?('jasmine/lib')
      raise "Jasmine submodule isn't present.  Run git submodule update --init"
    end

    require "fileutils"

    # copy jasmine's example tree into our generator templates dir
    FileUtils.rm_r('generators/jasmine/templates/jasmine-example', :force => true)
    FileUtils.cp_r('jasmine/example', 'generators/jasmine/templates/jasmine-example', :preserve => true)
  end
end

desc "Run specs via server"
task :jasmine => ['jasmine:server']

desc "Install Bundle"
task "bundle_install" do
  `bundle install`
end


require 'bundler'
Bundler::GemHelper.install_tasks
