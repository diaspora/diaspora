# frozen_string_literal: true

namespace :ci do
  task prepare_db: %w[db:create db:migrate]
  task prepare: %w[prepare_db assets:generate_error_pages]

  desc "Run everyhting except cucumber"
  task other: %w[prepare tests:generate_fixtures spec]

  desc "Run cucumber"
  task cucumber: %w[prepare rake:cucumber]
end

if defined?(RSpec)
  namespace :tests do
    desc "Run all specs that generate fixtures for rspec or jasmine"
    RSpec::Core::RakeTask.new(:generate_fixtures => 'spec:prepare') do |t|
      t.rspec_opts = ['--tag fixture']
    end
  end
end
