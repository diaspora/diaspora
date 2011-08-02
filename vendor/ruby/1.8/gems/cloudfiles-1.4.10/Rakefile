require './lib/cloudfiles.rb'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "cloudfiles"
    gemspec.summary = "A Ruby API into Rackspace Cloud Files"
    gemspec.description = "A Ruby version of the Rackspace Cloud Files API."
    gemspec.email = "minter@lunenburg.org"
    gemspec.homepage = "http://www.rackspacecloud.com/cloud_hosting_products/files"
    gemspec.authors = ["H. Wade Minter", "Rackspace Hosting"]
    gemspec.add_dependency('mime-types', '>= 1.16')
    gemspec.add_development_dependency "mocha", "~> 0.9.8"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end 

namespace :test do
  desc 'Check test coverage'
  task :coverage do
    rm_f "coverage"
    system("rcov -x '/Library/Ruby/Gems/1.8/gems/' --sort coverage #{File.join(File.dirname(__FILE__), 'test/*_test.rb')}")
    system("open #{File.join(File.dirname(__FILE__), 'coverage/index.html')}") if PLATFORM['darwin']
  end

  desc 'Remove coverage products'
  task :clobber_coverage do
    rm_r 'coverage' rescue nil
  end

end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end
