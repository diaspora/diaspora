require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mixlib-log"
    gem.summary = "A gem that provides a simple mixin for log functionality"
    gem.email = "info@opscode.com"
    gem.homepage = "http://www.opscode.com"
    gem.authors = ["Opscode, Inc."]
    gem.files.include %w{ bin/* lib/**/* }
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  STDERR.puts
  STDERR.puts "Jeweler is not installed. (sudo) gem install jeweler to use gem packaging tasks"
  STDERR.puts
end

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new(:spec) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
    spec.spec_files = FileList['spec/**/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:rcov) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rcov = true
  end
rescue LoadError
  task :spec do
    abort "Rspec is not available. (sudo) gem install rspec to run unit tests"
  end
end


begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

task :default => :spec

require 'rake/rdoctask'
require 'yaml'

Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mixlib-log #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

