require 'rspec/core'
require 'rspec/core/rake_task'
Rake.application.instance_variable_get('@tasks')['default'].prerequisites.delete('test')

spec_prereq = Rails.configuration.generators.options[:rails][:orm] == :active_record ?  "db:test:prepare" : :noop
task :noop do; end
task :default => :spec

task :stats => "spec:statsetup"

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec => spec_prereq)

namespace :spec do
  [:requests, :models, :controllers, :views, :helpers, :mailers, :lib, :routing].each do |sub|
    desc "Run the code examples in spec/#{sub}"
    RSpec::Core::RakeTask.new(sub => spec_prereq) do |t|
      t.pattern = "./spec/#{sub}/**/*_spec.rb"
    end
  end

  desc "Run all specs with rcov"
  RSpec::Core::RakeTask.new(:rcov => spec_prereq) do |t|
    t.rcov = true
    t.pattern = "./spec/**/*_spec.rb"
    t.rcov_opts = '--exclude /gems/,/Library/,/usr/,lib/tasks,.bundle,config,/lib/rspec/,/lib/rspec-'
  end

  task :statsetup do
    require 'rails/code_statistics'
    ::STATS_DIRECTORIES << %w(Model\ specs spec/models) if File.exist?('spec/models')
    ::STATS_DIRECTORIES << %w(View\ specs spec/views) if File.exist?('spec/views')
    ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers) if File.exist?('spec/controllers')
    ::STATS_DIRECTORIES << %w(Helper\ specs spec/helpers) if File.exist?('spec/helpers')
    ::STATS_DIRECTORIES << %w(Library\ specs spec/lib) if File.exist?('spec/lib')
    ::STATS_DIRECTORIES << %w(Mailer\ specs spec/mailers) if File.exist?('spec/mailers')
    ::STATS_DIRECTORIES << %w(Routing\ specs spec/routing) if File.exist?('spec/routing')
    ::STATS_DIRECTORIES << %w(Request\ specs spec/requests) if File.exist?('spec/requests')
    ::CodeStatistics::TEST_TYPES << "Model specs" if File.exist?('spec/models')
    ::CodeStatistics::TEST_TYPES << "View specs" if File.exist?('spec/views')
    ::CodeStatistics::TEST_TYPES << "Controller specs" if File.exist?('spec/controllers')
    ::CodeStatistics::TEST_TYPES << "Helper specs" if File.exist?('spec/helpers')
    ::CodeStatistics::TEST_TYPES << "Library specs" if File.exist?('spec/lib')
    ::CodeStatistics::TEST_TYPES << "Mailer specs" if File.exist?('spec/mailer')
    ::CodeStatistics::TEST_TYPES << "Routing specs" if File.exist?('spec/routing')
    ::CodeStatistics::TEST_TYPES << "Request specs" if File.exist?('spec/requests')
  end
end

