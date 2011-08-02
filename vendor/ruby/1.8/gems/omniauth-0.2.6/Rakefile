#!/usr/bin/env rake

$:.unshift File.expand_path('..', __FILE__)
require 'tasks/all'

desc 'Clean up temporary files'
task :clean => 'all:clean'

desc 'Build gem files for all projects into the package directory'
task :build => 'all:build'

desc 'Build and install gems for all projects'
task :install => 'all:install'

desc 'Write version with MAJOR, MINOR, PATCH, and PRE environment variables'
task 'version:write' => 'all:version:write'

desc 'Display the current version for all projects'
task :version => 'all:version'
desc 'Increment the major version for all projects'
task 'version:bump:major' => 'all:version:bump:major'
desc 'Increment the minor version for all projects'
task 'version:bump:minor' => 'all:version:bump:minor'
desc 'Increment the patch version for all projects'
task 'version:bump:patch' => 'all:version:bump:patch'

desc 'Run specs for all projects'
task :spec => 'all:spec'
task :test => :spec
task :default => :test

desc 'Generate docs for all projects'
task 'doc:yard' => 'all:doc:yard'

task :tag do
  sh "git tag -a -m \"Version #{version}\" v#{version}"
  sh "git push"
  sh "git push --tags"
end

task :push => 'all:push'

desc 'Build, tag, and push gems for all projects to Rubygems'
task :release => [:build, :tag, :push]

namespace :doc do
  require 'yard'
  YARD::Rake::YardocTask.new do |task|
    task.files = PROJECTS.map{|project| "#{root}/#{project}/lib/**/*.rb"} + ['README.markdown', 'LICENSE']
  end
end
