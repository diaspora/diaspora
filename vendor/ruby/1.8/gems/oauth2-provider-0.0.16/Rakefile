require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

namespace :spec do
  desc "Run specs using the active_record backend"
  RSpec::Core::RakeTask.new(:activerecord) do |t|
    t.rspec_opts = "-f n -c"
    t.pattern = "spec/**/*_spec.rb"
  end

  desc "Run specs using the mongoid backend"
  RSpec::Core::RakeTask.new(:mongoid) do |t|
    t.rspec_opts = "-f n -c"
    t.pattern = "spec/**/*_spec.rb"
    t.ruby_opts = "-Ispec -rset_backend_env_to_mongoid"
  end

  desc "Run specs using both backends"
  task :all => ['spec:activerecord', 'spec:mongoid']
end

task :default => 'spec:all'