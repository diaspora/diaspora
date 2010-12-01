require "rake/rdoctask"
require "rake/testtask"
require "rake/gempackagetask"

require "rubygems"

dir     = File.dirname(__FILE__)
lib     = File.join(dir, "lib", "faster_csv.rb")
version = File.read(lib)[/^\s*VERSION\s*=\s*(['"])(\d\.\d\.\d)\1/, 2]

task :default => [:test]

Rake::TestTask.new do |test|
	test.libs       << "test"
	test.test_files =  %w[test/ts_all.rb]
	test.verbose    =  true
end

Rake::RDocTask.new do |rdoc|
	rdoc.main     = "README"
	rdoc.rdoc_dir = "doc/html"
	rdoc.title    = "FasterCSV Documentation"
	rdoc.rdoc_files.include( "README",  "INSTALL",
	                         "TODO",    "CHANGELOG",
	                         "AUTHORS", "COPYING",
	                         "LICENSE", "lib/" )
end

desc "Upload current documentation to Rubyforge"
task :upload_docs => [:rdoc] do
	sh "scp -r doc/html/* " +
	   "bbazzarrakk@rubyforge.org:/var/www/gforge-projects/fastercsv/"
end

desc "Show library's code statistics"
task :stats do
	require 'code_statistics'
	CodeStatistics.new( ["FasterCSV", "lib"], 
	                    ["Units",     "test"] ).to_s
end

desc "Time FasterCSV and CSV"
task :benchmark do
  TESTS = 6
  path = "test/test_data.csv"
	sh %Q{time ruby -r csv -e } +
	   %Q{'#{TESTS}.times { CSV.foreach("#{path}") { |row| } }'}
	sh %Q{time ruby -r lib/faster_csv -e } +
	   %Q{'#{TESTS}.times { FasterCSV.foreach("#{path}") { |row| } }'}
end

spec = Gem::Specification.new do |spec|
	spec.name    = "fastercsv"
	spec.version = version

	spec.platform = Gem::Platform::RUBY
	spec.summary  = "FasterCSV is CSV, but faster, smaller, and cleaner."

	spec.test_files      = %w[test/ts_all.rb]
	spec.files           = Dir.glob("{lib,test,examples}/**/*.rb").
	                           reject { |item| item.include?(".svn") } +
	                       Dir.glob("{test,examples}/**/*.csv").
	                           reject { |item| item.include?(".svn") } +
	                       %w[Rakefile setup.rb test/line_endings.gz]

	spec.has_rdoc         = true
	spec.extra_rdoc_files = %w[ AUTHORS COPYING README INSTALL TODO CHANGELOG
	                            LICENSE ]
	spec.rdoc_options     << "--title" << "FasterCSV Documentation" <<
	                         "--main"  << "README"

	spec.require_path = "lib"

	spec.author            = "James Edward Gray II"
	spec.email             = "james@grayproductions.net"
	spec.rubyforge_project = "fastercsv"
	spec.homepage          = "http://fastercsv.rubyforge.org"
	spec.description       = <<END_DESC
FasterCSV is intended as a complete replacement to the CSV standard library. It
is significantly faster and smaller while still being pure Ruby code. It also
strives for a better interface.
END_DESC
end

Rake::GemPackageTask.new(spec) do |pkg|
	pkg.need_zip = true
	pkg.need_tar = true
end

desc "Add new files to Subversion"
task :add_to_svn do
  sh %Q{svn status | ruby -nae 'system "svn add \#{$F[1]}" if $F[0] == "?"' }
end
