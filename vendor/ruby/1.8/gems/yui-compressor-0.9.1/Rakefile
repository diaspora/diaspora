require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"
require "rake/testtask"

task :default => :test

Rake::TestTask.new do |t|
  t.libs += ["lib", "test"]
  t.test_files = FileList["test/*_test.rb"]
  t.verbose = true
end

Rake::RDocTask.new do |t|
  t.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

Rake::GemPackageTask.new(eval(IO.read(File.join(File.dirname(__FILE__), "yui-compressor.gemspec")))) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
