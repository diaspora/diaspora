# encoding: utf-8

desc "Run AMQP 0-8 rspec tests"
task :spec08 do
  require 'rspec/core/rake_task'
  puts "===== Running 0-8 tests ====="
  RSpec::Core::RakeTask.new("spec08") do |t|
    t.pattern = "spec/spec_08/*_spec.rb"
    t.rspec_opts = ['--color']
  end
end

desc "Run AMQP 0-9 rspec tests"
task :spec09 do
  require 'rspec/core/rake_task'
  puts "===== Running 0-9 tests ====="
  RSpec::Core::RakeTask.new("spec09") do |t|
    t.pattern = "spec/spec_09/*_spec.rb"
    t.rspec_opts = ['--color']
  end
end

task :default => [ :spec08 ]

desc "Run all rspec tests"
task :all => [:spec08, :spec09]
