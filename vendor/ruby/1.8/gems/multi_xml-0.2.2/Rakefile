require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :test => :spec
task :default => :spec

namespace :doc do
  require 'yard'
  YARD::Rake::YardocTask.new do |task|
    task.files   = ['LICENSE.mkd', 'lib/**/*.rb']
    task.options = [
      '--no-private',
      '--protected',
      '--output-dir', 'doc/yard',
      '--markup', 'markdown',
    ]
  end
end
