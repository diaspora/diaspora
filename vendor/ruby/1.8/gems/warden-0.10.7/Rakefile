require 'rubygems'
gem 'rspec'
require 'spec/rake/spectask'
require File.join(File.dirname(__FILE__), "lib", "warden", "version")

begin
  gem 'jeweler'
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "warden"
    gem.version = Warden::VERSION
    gem.summary = "Rack middleware that provides authentication for rack applications"
    gem.email = "has.sox@gmail.com"
    gem.homepage = "http://github.com/hassox/warden"
    gem.authors = ["Daniel Neighman"]
    gem.rubyforge_project = "warden"
    gem.add_dependency "rack", ">= 1.0.0"
    gem.add_development_dependency "rspec", ">= 1.0.0"
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

task :default => :spec

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(-fs --color --backtrace)
end
