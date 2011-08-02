# Rakefile for rubyntlm    -*- ruby -*-
# $Id: Rakefile,v 1.2 2006/10/05 01:36:52 koheik Exp $

require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require File.join(File.dirname(__FILE__), 'lib', 'net', 'ntlm')

PKG_NAME = 'rubyntlm'
PKG_VERSION = Net::NTLM::VERSION::STRING

task :default => [:test]

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList[ "test/*.rb" ]
  t.warning = true
  t.verbose = true
end

# Rake::PackageTask.new(PKG_NAME, PKG_VERSION) do |p|
#   p.need_tar_gz = true
#   p.package_dir = 'build'
#   p.package_files.include("README", "Rakefile")
#   p.package_files.include("lib/net/**/*.rb", "test/**/*.rb", "examples/**/*.rb")
# end

Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'doc'
  rd.title = 'Ruby/NTLM library'
  rd.main = "README"
  rd.rdoc_files.include("README", "lib/**/*.rb")
end

dist_dirs = ["lib", "test", "examples"]
spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = %q{Ruby/NTLM library.}
  s.description = %q{Ruby/NTLM provides message creator and parser for the NTLM authentication.}
  s.authors = ["Kohei Kajimoto"]
  s.email = %q{koheik@gmail.com}
  s.homepage = %q{http://rubyforge.org/projects/rubyntlm}
  s.rubyforge_project = %q{rubyntlm}

  s.files = ["Rakefile", "README"]
  dist_dirs.each do |dir|
    s.files = s.files + Dir.glob("#{dir}/**/*.rb")
  end
  
  s.has_rdoc = true
  s.extra_rdoc_files = %w( README )
  s.rdoc_options.concat ['--main', 'README']
  
  s.autorequire = 'net/ntlm'
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
  p.package_dir = 'build'
end

  
  