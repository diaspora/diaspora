require 'rubygems'
require 'rubygems/user_interaction'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => [:test]

# Test --------------------------------------------------------------------

desc "Run the unit tests"
task :test do
  Rake::TestTask.new("test") do |t|
    t.libs << "tests"
    t.pattern = 'tests/*_test.rb'
    t.verbose = true
  end
end

# Documentation -----------------------------------------------------------
desc "Generate RDoc"
rd = Rake::RDocTask.new("rdoc") { |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "POpen4 -- Open4 cross-platform"
  rdoc.options << '--main' << 'README'
  rdoc.rdoc_files.include('README', 'LICENSE', 'CHANGES')
  rdoc.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc')
}

# GEM Packaging -----------------------------------------------------------

begin
  require 'jeweler'
  # Windows
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "POpen4"
    gemspec.summary = "Open4 cross-platform"
    gemspec.description = ""
    gemspec.email = "john-mason@shackelford.org"
    gemspec.homepage = "http://github.com/pka/popen4"
    gemspec.authors = ["John-Mason P. Shackelford"]
    gemspec.add_dependency("Platform",   ">= 0.4.0")
    gemspec.platform = 'x86-mswin32'
    gemspec.add_dependency("win32-open3")
  end
  # Unix
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "POpen4"
    gemspec.summary = "Open4 cross-platform"
    gemspec.description = ""
    gemspec.email = "john-mason@shackelford.org"
    gemspec.homepage = "http://github.com/pka/popen4"
    gemspec.authors = ["John-Mason P. Shackelford"]
    gemspec.add_dependency("Platform",   ">= 0.4.0")
    gemspec.add_dependency("open4")
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
