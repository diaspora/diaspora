namespace :ci do
  namespace :travis do
    desc "Run everyhting except cucumber"
    task :other => [ :prepare_db, "tests:generate_fixtures", :spec, "jasmine:ci" ]
    
    desc "Run cucumber"
    task :cucumber => [ :prepare_db, "assets:precompile", "rake:cucumber" ]
    
    desc "Prepare db"
    task :prepare_db => [ "db:create", "db:test:load"]
  end
end

if defined?(RSpec)
  namespace :tests do
    desc "Run all specs that generate fixtures for rspec or jasmine"
    RSpec::Core::RakeTask.new(:generate_fixtures) do |t|
      t.rspec_opts = ['--tag fixture']
    end
  end
end
