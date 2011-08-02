require "bundler"
Bundler.setup

require 'rake'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "activerecord-import"
    gem.summary = %Q{Bulk-loading extension for ActiveRecord}
    gem.description = %Q{Extraction of the ActiveRecord::Base#import functionality from ar-extensions for Rails 3 and beyond}
    gem.email = "zach.dennis@gmail.com"
    gem.homepage = "http://github.com/zdennis/activerecord-import"
    gem.authors = ["Zach Dennis"]
    gem.files = FileList["VERSION", "Rakefile", "README*", "lib/**/*"]

    bundler = Bundler.load
    bundler.dependencies_for(:default).each do |dependency|
      gem.add_dependency dependency.name, *dependency.requirements_list
    end

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

namespace :display do
  task :notice do
    puts
    puts "To run tests you must supply the adapter, see rake -T for more information."
    puts
  end
end
task :default => ["display:notice"]

ADAPTERS = %w(mysql mysql2 postgresql sqlite3)
ADAPTERS.each do |adapter|
  namespace :test do
    desc "Runs #{adapter} database tests."
    Rake::TestTask.new(adapter) do |t|
      # FactoryGirl has an issue with warnings, so turn off, so noisy
      # t.warning = true
      t.test_files = FileList["test/adapters/#{adapter}.rb", "test/*_test.rb", "test/active_record/*_test.rb", "test/#{adapter}/**/*_test.rb"]
    end
    task adapter
  end
end

begin
  require 'rcov/rcovtask'
  adapter = ENV['ARE_DB']
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = ["test/adapters/#{adapter}.rb", "test/*_test.rb", "test/#{adapter}/**/*_test.rb"]
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install rcov"
  end
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "activerecord-import #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
