begin
  require 'rake/gempackagetask'
rescue LoadError
end
require 'rake/clean'
require 'rbconfig'
include Config

PKG_NAME = 'term-ansicolor'
PKG_VERSION = File.read('VERSION').chomp
PKG_FILES = FileList['**/*'].exclude(/(CVS|\.svn|pkg|coverage|doc)/)
CLEAN.include 'coverage', 'doc'

desc "Installing library"
task :install  do
  ruby 'install.rb'
end

desc "Creating documentation"
task :doc do
  ruby 'make_doc.rb'
end


if defined? Gem
  spec = Gem::Specification.new do |s|
    s.name = PKG_NAME
    s.version = PKG_VERSION
    s.summary = "Ruby library that colors strings using ANSI escape sequences"
    s.description = ""

    s.files = PKG_FILES.to_a.sort

    s.require_path = 'lib'

    s.has_rdoc = true
    s.extra_rdoc_files << 'README'
    s.executables << 'cdiff' << 'decolor'
    s.rdoc_options << '--main' <<  'README' << '--title' << 'Term::ANSIColor'
    s.test_files = Dir['tests/*.rb']

    s.author = "Florian Frank"
    s.email = "flori@ping.de"
    s.homepage = "http://flori.github.com/#{PKG_NAME}"
    s.rubyforge_project = PKG_NAME
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
    pkg.package_files += PKG_FILES
  end
end

desc m = "Writing version information for #{PKG_VERSION}"
task :version do
  puts m
  File.open(File.join('lib', 'term', 'ansicolor', 'version.rb'), 'w') do |v|
    v.puts <<EOT
module Term
  module ANSIColor
    # Term::ANSIColor version
    VERSION         = '#{PKG_VERSION}'
    VERSION_ARRAY   = VERSION.split(/\\./).map { |x| x.to_i } # :nodoc:
    VERSION_MAJOR   = VERSION_ARRAY[0] # :nodoc:
    VERSION_MINOR   = VERSION_ARRAY[1] # :nodoc:
    VERSION_BUILD   = VERSION_ARRAY[2] # :nodoc:
  end
end
EOT
  end
end

desc "Run tests"
task :tests do
  sh 'testrb -Ilib tests/*.rb'
end
task :test => :tests

desc "Run tests with coverage"
task :coverage do
  sh 'rcov -Ilib tests/*.rb'
end

desc "Default"
task :default => [ :version ]

desc "Prepare a release"
task :release => [ :clean, :version, :package ]
