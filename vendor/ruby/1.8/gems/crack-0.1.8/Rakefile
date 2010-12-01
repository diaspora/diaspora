require 'rubygems'
require 'rake'
require File.expand_path('../lib/crack', __FILE__)

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "crack"
    gem.summary = %Q{Really simple JSON and XML parsing, ripped from Merb and Rails.}
    gem.email = "nunemaker@gmail.com"
    gem.homepage = "http://github.com/jnunemaker/crack"
    gem.authors = ["John Nunemaker", "Wynn Netherland"]
    gem.rubyforge_project = 'crack'
    gem.version = Crack::VERSION
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'crack'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end


task :default => :test