require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "hashie"
    gem.summary = %Q{Your friendly neighborhood hash toolkit.}
    gem.description = %Q{Hashie is a small collection of tools that make hashes more powerful. Currently includes Mash (Mocking Hash) and Dash (Discrete Hash).}
    gem.email = "michael@intridea.com"
    gem.homepage = "http://github.com/intridea/hashie"
    gem.authors = ["Michael Bleigh"]
    gem.add_development_dependency "rspec"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |spec|
  # spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hashie #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
