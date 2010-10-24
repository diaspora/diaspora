#!/usr/bin/env ruby
require 'fileutils'
include FileUtils

def root_dir
  @root_dir ||= File.expand_path(File.dirname(__FILE__) + '/../..')
end

def rake(*tasks)
  tasks.each do |task|
    return false unless system("rake", task, 'RAILS_ENV=test')
  end
end

build_results = {}

cd root_dir do
  build_results[:bundle] = system 'bundle install' # bundling here, rather than in a task (not in Rails context)
  build_results[:spec] = rake 'cruise'
end

failures = build_results.select { |key, value| value == false }

if failures.empty?
  exit(0)
else
  exit(-1)
end
