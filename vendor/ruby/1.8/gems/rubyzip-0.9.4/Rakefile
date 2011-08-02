# Rakefile for RubyGems      -*- ruby -*-

require 'rubygems'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/sshpublisher'
require 'net/sftp'

PKG_NAME = 'rubyzip'
PKG_VERSION = File.read('lib/zip/zip.rb').match(/\s+VERSION\s*=\s*'(.*)'/)[1]

PKG_FILES = FileList.new

PKG_FILES.add %w{ README NEWS TODO ChangeLog install.rb Rakefile }
PKG_FILES.add %w{ samples/*.rb }
PKG_FILES.add %w{ test/*.rb }
PKG_FILES.add %w{ test/data/* }
PKG_FILES.exclude "test/data/generated"
PKG_FILES.add %w{ lib/**/*.rb }

def clobberFromCvsIgnore(path)
  CLOBBER.add File.readlines(path+'/.cvsignore').map { 
    |f| File.join(path, f.chomp) 
  } rescue StandardError
end

clobberFromCvsIgnore '.'
clobberFromCvsIgnore 'samples'
clobberFromCvsIgnore 'test'
clobberFromCvsIgnore 'test/data'

def rsystem(cmd)
  system(cmd) or raise "system command failed: '#{cmd}"
end

task :default => [:test]

desc "Run unit tests"
task :test do
  ruby %{-C test alltests.rb}
end

# Shortcuts for test targets
task :ut => [:test]

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.author = "Thomas Sondergaard"
  s.email = "thomas(at)sondergaard.cc"
  s.homepage = "http://rubyzip.sourceforge.net/"
  s.platform = Gem::Platform::RUBY
  s.summary = "rubyzip is a ruby module for reading and writing zip files"
  s.files = PKG_FILES.to_a
  s.require_path = 'lib'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_files.add %W{ lib/zip/*.rb README NEWS TODO ChangeLog }
  rd.options << "-t 'rubyzip documentation' --webcvs http://cvs.sourceforge.net/viewcvs.py/rubyzip/rubyzip/"
#  rd.options << "--all"
end

desc "Publish documentation"
task :pdoc => [:rdoc] do
  rsystem("rsync -avz --delete html/* thomas,rubyzip@frs.sourceforge.net:/home/groups/r/ru/rubyzip/htdocs")
end

desc "Publish package"
task :ppackage => [:package] do
  Net::SFTP.start("frs.sourceforge.net", "thomas,rubyzip") do
    |ftpclient|
    releasedir = File.join("/home/pfs/project/r/ru/rubyzip/rubyzip", PKG_VERSION)
    ftpclient.mkdir releasedir
    Dir['pkg/*.{tgz,zip,gem}'].each do
      |e|
      ftpclient.upload!(e, File.join(releasedir, File.basename(e)))
    end
  end
end

desc "Generate the ChangeLog file"
task :ChangeLog do
  puts "Updating ChangeLog"
  system %{cvs2cl}
end

desc "Make a release"
task :release => [:tag_release, :pdoc, :ppackage] do
end

desc "Make a release tag"
task :tag_release do
  tag = "release-#{PKG_VERSION.gsub('.','-')}"

  puts "Checking for tag '#{tag}'"
  if (Regexp.new("^\\s+#{tag}") =~ `cvs log README`)
    abort "Tag '#{tag}' already exists"
  end
  puts "Tagging module with '#{tag}'"
  system("cvs tag #{tag}")
end
