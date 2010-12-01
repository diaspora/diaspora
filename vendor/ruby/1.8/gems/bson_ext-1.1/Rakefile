# -*- mode: ruby; -*-
require 'rubygems'
require 'rubygems/specification'
require 'fileutils'
require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'
begin
  require 'rake/contrib/rubyforgepublisher'
rescue LoadError
end
require 'rbconfig'
include Config
ENV['TEST_MODE'] = 'TRUE'

task :java do
  Rake::Task['build:java'].invoke
  Rake::Task['test:ruby'].invoke
end

namespace :build do
  desc "Build the java extensions."
  task :java do
    puts "Building Java extensions..."
    java_dir  = File.join(File.dirname(__FILE__), 'ext', 'java')
    jar_dir   = File.join(java_dir, 'jar')

    jruby_jar = File.join(jar_dir, 'jruby.jar')
    mongo_jar = File.join(jar_dir, 'mongo.jar')
    bson_jar = File.join(jar_dir, 'bson.jar')

    src_base   = File.join(java_dir, 'src')

    system("javac -Xlint:unchecked -classpath #{jruby_jar}:#{mongo_jar}:#{bson_jar} #{File.join(src_base, 'org', 'jbson', '*.java')}")
    system("cd #{src_base} && jar cf #{File.join(jar_dir, 'jbson.jar')} #{File.join('.', 'org', 'jbson', '*.class')}")
  end
end

desc "Test the MongoDB Ruby driver."
task :test do
  puts "\nThis option has changed."
  puts "\nTo test the driver with the c-extensions:\nrake test:c\n"
  puts "To test the pure ruby driver: \nrake test:ruby"
end

namespace :test do

  desc "Test the driver with the c extension enabled."
  task :c do
    ENV['C_EXT'] = 'TRUE'
    Rake::Task['test:unit'].invoke
    Rake::Task['test:functional'].invoke
    Rake::Task['test:bson'].invoke
    Rake::Task['test:pooled_threading'].invoke
    Rake::Task['test:drop_databases'].invoke
    ENV['C_EXT'] = nil
  end

  desc "Test the driver using pure ruby (no c extension)"
  task :ruby do
    ENV['C_EXT'] = nil
    Rake::Task['test:unit'].invoke
    Rake::Task['test:functional'].invoke
    Rake::Task['test:bson'].invoke
    Rake::Task['test:pooled_threading'].invoke
    Rake::Task['test:drop_databases'].invoke
  end
  
  Rake::TestTask.new(:unit) do |t|
    t.test_files = FileList['test/unit/*_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:functional) do |t|
    t.test_files = FileList['test/*_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:pooled_threading) do |t|
    t.test_files = FileList['test/threading/*.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:replica_pair_count) do |t|
    t.test_files = FileList['test/replica_pairs/count_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:replica_pair_insert) do |t|
    t.test_files = FileList['test/replica_pairs/insert_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:pooled_replica_pair_insert) do |t|
    t.test_files = FileList['test/replica_pairs/pooled_insert_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:replica_pair_query) do |t|
    t.test_files = FileList['test/replica_pairs/query_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:replica_set_count) do |t|
    t.test_files = FileList['test/replica_sets/count_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:replica_set_insert) do |t|
    t.test_files = FileList['test/replica_sets/insert_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:pooled_replica_set_insert) do |t|
    t.test_files = FileList['test/replica_sets/pooled_insert_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:replica_set_query) do |t|
    t.test_files = FileList['test/replica_sets/query_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:replica_set_ack) do |t|
    t.test_files = FileList['test/replica_sets/replication_ack_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:auto_reconnect) do |t|
    t.test_files = FileList['test/auxillary/autoreconnect_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:authentication) do |t|
    t.test_files = FileList['test/auxillary/authentication_test.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:new_features) do |t|
    t.test_files = FileList['test/auxillary/1.4_features.rb']
    t.verbose    = true
  end

  Rake::TestTask.new(:bson) do |t|
    t.test_files = FileList['test/mongo_bson/*_test.rb']
    t.verbose    = true
  end

  task :drop_databases do |t|
    puts "Dropping test database..."
    require File.join(File.dirname(__FILE__), 'test', 'test_helper')
    include Mongo
    con = Connection.new(ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost',
      ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT)
    con.drop_database(MONGO_TEST_DB)
  end
end

desc "Generate documentation"
task :rdoc do
  version = eval(File.read("mongo.gemspec")).version
  out = File.join('html', version.to_s)
  FileUtils.rm_rf('html')
  system "rdoc --main README.rdoc --op #{out} --inline-source --quiet README.rdoc `find lib -name '*.rb'`"
end

desc "Generate YARD documentation"
task :ydoc do
  require File.join(File.dirname(__FILE__), 'lib', 'mongo')
  out = File.join('ydoc', Mongo::VERSION)
  FileUtils.rm_rf('ydoc')
  system "yardoc lib/**/*.rb lib/mongo/**/*.rb lib/bson/**/*.rb -e docs/yard_ext.rb -p docs/templates -o #{out} --title MongoRuby-#{Mongo::VERSION}"
end

desc "Publish documentation to mongo.rubyforge.org"
task :publish => [:rdoc] do
  # Assumes docs are in ./html
  Rake::RubyForgePublisher.new(GEM, RUBYFORGE_USER).upload
end

namespace :gem do

  desc "Install the gem locally"
  task :install do
    sh "gem build bson.gemspec"
    sh "gem install bson-*.gem"
    sh "gem build mongo.gemspec"
    sh "gem install mongo-*.gem"
    sh "rm mongo-*.gem"
    sh "rm bson-*.gem"
  end

  desc "Install the optional c extensions"
  task :install_extensions do
    sh "gem build bson_ext.gemspec"
    sh "gem install bson_ext-*.gem"
    sh "rm bson_ext-*.gem"
  end

end

task :default => :list

task :list do
  system 'rake -T'
end
