$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/lib")
require "bundler"
Bundler.setup

require 'spec'
require 'spec/rake/spectask'

desc "Run all examples"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

namespace :jasmine do
  require 'spec/jasmine_self_test_config'
  task :server do
    puts "your tests are here:"
    puts "  http://localhost:8888/"

    JasmineSelfTestConfig.new.start_server
  end

  desc "Copy examples from Jasmine JS to the gem"
  task :copy_examples_to_gem do
    unless File.exists?('jasmine/lib')
      raise "Jasmine submodule isn't present.  Run git submodule update --init"
    end

    system "ruby copy_examples.rb"
  end
end

desc "Run specs via server"
task :jasmine => ['jasmine:server']

namespace :jeweler do
  begin
    require "jeweler"
    Jeweler::Tasks.new do |gemspec|
      gemspec.name = "jasmine"
      gemspec.summary = "Jasmine Runner for Ruby"
      gemspec.description = "Javascript BDD test framework"
      gemspec.email = "jasmine-js@googlegroups.com"
      gemspec.homepage = "http://pivotal.github.com/jasmine"
      gemspec.authors = ["Rajan Agaskar", "Christian Williams", "Davis Frank"]
      gemspec.executables = ["jasmine"]
      gemspec.add_dependency('rake', '>= 0.8.7')
      gemspec.add_dependency('rspec', '>= 1.1.5')
      gemspec.add_dependency('rack', '>= 1.0.0')
      gemspec.add_dependency('selenium-rc', '>=2.1.0')
      gemspec.add_dependency('selenium-client', '>=1.2.17')
      gemspec.add_dependency('json_pure', '>=1.4.3')
    end
    Jeweler::GemcutterTasks.new
  end

  task :setup_filelist do
    Rake.application.jeweler_tasks.gemspec.files = FileList.new(
          'generators/**/**',
          'lib/**/**',
          'jasmine/lib/jasmine.css',
          'jasmine/lib/jasmine.js',
          'jasmine/lib/jasmine-html.js',
          'jasmine/lib/json2.js',    # try to get rid of this
          'jasmine/example/**',
          'tasks/**',
          'templates/**'
      )
  end
end

Rake.application["jeweler:gemspec"].prerequisites.unshift("jeweler:setup_filelist").unshift("jasmine:copy_examples_to_gem")
