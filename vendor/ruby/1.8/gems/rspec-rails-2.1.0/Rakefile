unless File.directory?("vendor/rails")
  raise <<-MESSAGE
You need to clone the rails git repository into ./vendor before you can use any
of the rake tasks.

    git clone git://github.com/rails/rails.git vendor/rails

MESSAGE
end
require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

require 'rake'
require 'yaml'

require 'rake/rdoctask'
require 'rspec'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end

Cucumber::Rake::Task.new(:cucumber)

namespace :spec do
  desc "Run all examples using rcov"
  RSpec::Core::RakeTask.new :rcov => :cleanup_rcov_files do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features"]
    t.rcov_opts << %[--text-report --sort coverage --no-html --aggregate coverage.data]
  end
end

namespace :cucumber do
  desc "Run cucumber features using rcov"
  Cucumber::Rake::Task.new :rcov => :cleanup_rcov_files do |t|
    t.cucumber_opts = %w{--format progress}
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features"]
    t.rcov_opts << %[--text-report --sort coverage --aggregate coverage.data]
  end
end

namespace :generate do
  desc "generate a fresh app with rspec installed"
  task :app do |t|
    unless File.directory?('./tmp/example_app')
      sh "bundle exec rails new ./tmp/example_app"
      sh "cp ./templates/Gemfile ./tmp/example_app/"
      sh "cp ./specs.watchr ./tmp/example_app/"
    end
  end

  desc "generate a bunch of stuff with generators"
  task :stuff do
    in_example_app "bundle install"
    in_example_app "rake rails:template LOCATION='../../templates/generate_stuff.rb'"
  end
end

def in_example_app(command)
  Dir.chdir("./tmp/example_app/") do
    Bundler.with_clean_env do
      sh command
    end
  end
end

namespace :db do
  task :migrate do
    in_example_app "rake db:migrate"
  end

  namespace :test do
    task :prepare do
      in_example_app "rake db:test:prepare"
    end
  end
end

desc "run a variety of specs against the generated app"
task :smoke do
  in_example_app "rake rails:template --trace LOCATION='../../templates/run_specs.rb'"
end

desc 'clobber generated files'
task :clobber do
  rm_rf "pkg"
  rm_rf "tmp"
  rm    "Gemfile.lock" if File.exist?("Gemfile.lock")
end

namespace :clobber do
  desc "clobber the generated app"
  task :app do
    rm_rf "tmp/example_app"
  end
end

desc "Push cukes to relishapp using the relish-client-gem"
task :relish, :version do |t, args|
  raise "rake relish[VERSION]" unless args[:version]
  sh "bundle exec relish --organization rspec --project rspec-rails -v #{args[:version]} push"
end

task :default => [:spec, "clobber:app", "generate:app", "generate:stuff", :smoke, :cucumber]


