require "rake/rdoctask"
require "rake/testtask"
require "rake/gempackagetask"

require "rubygems"

dir     = File.dirname(__FILE__)
lib     = File.join(dir, "lib", "highline.rb")
version = File.read(lib)[/^\s*VERSION\s*=\s*(['"])(\d\.\d\.\d)\1/, 2]

task :default => [:test]

Rake::TestTask.new do |test|
  test.libs       << "test"
  test.test_files =  [ "test/ts_all.rb" ]
  test.verbose    =  true
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README", "INSTALL",
                           "TODO", "CHANGELOG",
                           "AUTHORS", "COPYING",
                           "LICENSE", "lib/" )
  rdoc.main     = "README"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "HighLine Documentation"
end

desc "Upload current documentation to Rubyforge"
task :upload_docs => [:rdoc] do
  sh "scp -r doc/html/* " +
     "bbazzarrakk@rubyforge.org:/var/www/gforge-projects/highline/doc/"
  sh "scp -r site/* " +
     "bbazzarrakk@rubyforge.org:/var/www/gforge-projects/highline/"
end

spec = Gem::Specification.new do |spec|
  spec.name     = "highline"
  spec.version  = version
  spec.platform = Gem::Platform::RUBY
  spec.summary  = "HighLine is a high-level command-line IO library."
  spec.files    = Dir.glob("{examples,lib,test}/**/*.rb").
                      delete_if { |item| item.include?("CVS") } +
                      ["Rakefile", "setup.rb"]

  spec.test_files       =  "test/ts_all.rb"
  spec.has_rdoc         =  true
  spec.extra_rdoc_files =  %w{README INSTALL TODO CHANGELOG LICENSE}
  spec.rdoc_options     << '--title' << 'HighLine Documentation' <<
                           '--main'  << 'README'

  spec.require_path      = 'lib'

  spec.author            = "James Edward Gray II"
  spec.email             = "james@grayproductions.net"
  spec.rubyforge_project = "highline"
  spec.homepage          = "http://highline.rubyforge.org"
  spec.description       = <<END_DESC
A high-level IO library that provides validation, type conversion, and more for
command-line interfaces. HighLine also includes a complete menu system that can
crank out anything from simple list selection to complete shells with just
minutes of work.
END_DESC
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Show library's code statistics"
task :stats do
  require 'code_statistics'
  CodeStatistics.new( ["HighLine", "lib"], 
                      ["Functionals", "examples"], 
                      ["Units", "test"] ).to_s
end

desc "Add new files to Subversion"
task :add_to_svn do
  sh %Q{svn status | ruby -nae 'system "svn add \#{$F[1]}" if $F[0] == "?"' }
end
