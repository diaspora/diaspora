namespace :db do
  desc 'Seed the current RAILS_ENV database from db/seeds.rb'
  task :seed do
    require 'db/seeds'
  end

  desc 'Delete the collections in the current RAILS_ENV database'
  task :delete do
    require 'config/environment'
    # Specifiy what models to remove
    Post.delete_all
    Person.delete_all
    Profile.delete_all
  end

  desc 'Purge and seed the current RAILS_ENV database using information from db/seeds.rb'
  task :reset do
    Rake::Task['db:delete'].invoke
    Rake::Task['db:seed'].invoke
  end
end
