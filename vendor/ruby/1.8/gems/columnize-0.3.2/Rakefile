#!/usr/bin/env rake
# -*- Ruby -*-
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'fileutils'

ROOT_DIR = File.dirname(__FILE__)
require File.join(ROOT_DIR, '/lib/version')

def gemspec
  @gemspec ||= eval(File.read('.gemspec'), binding, '.gemspec')
end

desc "Build the gem"
task :package=>:gem
task :gem=>:gemspec do
  Dir.chdir(ROOT_DIR) do
    sh "gem build .gemspec"
    FileUtils.mkdir_p 'pkg'
    FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", 'pkg'
  end
end

desc "Install the gem locally"
task :install => :gem do
  Dir.chdir(ROOT_DIR) do
    sh %{gem install --local pkg/#{gemspec.name}-#{gemspec.version}}
  end
end

desc "Test everything."
Rake::TestTask.new(:test) do |t|
  t.libs << './lib'
  t.pattern = 'test/test-*.rb'
  t.verbose = true
end
task :test => :lib 

desc "same as test"
task :check => :test

desc "Create a GNU-style ChangeLog via svn2cl"
task :ChangeLog do
  system("svn2cl --authors=svn2cl_usermap")
end

task :default => [:test]

desc "Remove built files"
task :clean => [:clobber_package, :clobber_rdoc]

desc "Generate the gemspec"
task :generate do
  puts gemspec.to_ruby
end

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

# ---------  RDoc Documentation ------
desc "Generate rdoc documentation"
Rake::RDocTask.new("rdoc") do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "Columnize #{Columnize::VERSION} Documentation"

  # Make the README file the start page for the generated html
  rdoc.options += %w(--main README)

  rdoc.rdoc_files.include('lib/*.rb', 'README', 'COPYING')
end
desc "Same as rdoc"
task :doc => :rdoc

task :clobber_package do
  FileUtils.rm_rf File.join(ROOT_DIR, 'pkg')
end

task :clobber_rdoc do
  FileUtils.rm_rf File.join(ROOT_DIR, 'doc')
end
