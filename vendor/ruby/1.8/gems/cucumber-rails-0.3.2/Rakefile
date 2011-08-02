# encoding: utf-8

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "cucumber-rails"
    gemspec.summary = "Cucumber Generators and Runtime for Rails"
    gemspec.description = "Cucumber Generators and Runtime for Rails"
    gemspec.email = "cukes@googlegroups.com"
    gemspec.homepage = "http://cukes.info"
    gemspec.authors = ["Dennis Blöte", "Aslak Hellesøy", "Rob Holland"]
    gemspec.homepage = "http://github.com/aslakhellesoy/cucumber-rails"

    gemspec.add_dependency 'cucumber', '>= 0.8.0'
    gemspec.add_development_dependency 'aruba', '>= 0.1.9'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

$:.unshift(File.dirname(__FILE__) + '/lib')
Dir["#{File.dirname(__FILE__)}/dev_tasks/*.rake"].sort.each { |ext| load ext }
task :default => :cucumber