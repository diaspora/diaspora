require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

require "rake"
require "yaml"

require "rake/rdoctask"
require "rspec/core/rake_task"
require "rspec/core/version"
require "cucumber/rake/task"

class Cucumber::Rake::Task::ForkedCucumberRunner
  # When cucumber shells out, we still need it to run in the context of our
  # bundle.
  def run
    sh "bundle exec #{RUBY} " + args.join(" ")
  end
end

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_path = 'bin/rspec'
  t.rspec_opts = %w[--color]
end

Cucumber::Rake::Task.new(:cucumber)

namespace :rcov do
  task :cleanup do
    rm_rf 'coverage.data'
  end

  RSpec::Core::RakeTask.new :spec do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features"]
    t.rcov_opts << %[--no-html --aggregate coverage.data]
  end

  Cucumber::Rake::Task.new :cucumber do |t|
    t.cucumber_opts = %w{--format progress}
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features"]
    t.rcov_opts << %[--text-report --sort coverage --aggregate coverage.data]
  end

end

task :rcov => ["rcov:cleanup", "rcov:spec", "rcov:cucumber"]

task :default => [:spec, :cucumber]

task :clobber do
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end

desc "Push cukes to relishapp using the relish-client-gem"
task :relish, :version do |t, args|
  raise "rake relish[VERSION]" unless args[:version]
  sh "relish push --organization rspec --project rspec-core -v #{args[:version]}"
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rspec-core #{RSpec::Core::Version::STRING}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

