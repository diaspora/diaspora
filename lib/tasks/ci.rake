namespace :ci do
  namespace :travis do
    desc "Run everyhting except cucumber"
    task :other => [ :prepare_db, :generate_fixtures, :spec, "jasmine:ci" ]
    
    desc "Run cucumber"
    task :cucumber => [ :prepare_db, "rake:cucumber" ]
    
    desc "Prepare db"
    task :prepare_db => [ "db:create", "db:test:load"]
  end
end
