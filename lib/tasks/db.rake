namespace :db do
  desc 'Seed the current RAILS_ENV database from db/seeds.rb'
  task :seed do

    puts "Seeding the database for #{RAILS_ENV}..."

    require 'db/seeds'
  end

  desc 'Delete the collections in the current RAILS_ENV database'
  task :purge do
    require 'config/environment'

    puts "Purging the database for #{RAILS_ENV}..."

    # Specifiy what models to remove
    Post.delete_all
    Person.delete_all
    Profile.delete_all
  end

  desc 'Purge and seed the current RAILS_ENV database using information from db/seeds.rb'
  task :reset do
    
    puts "Resetting the database for #{RAILS_ENV}".upcase
    Rake::Task['db:purge'].invoke
    Rake::Task['db:seed'].invoke
    puts "Success!"
  end
end
