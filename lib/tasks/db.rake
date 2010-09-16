#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



namespace :db do
  desc 'Seed the current RAILS_ENV database from db/seeds.rb'
  namespace :seed do
    task :tom do
      puts "Seeding the database for #{Rails.env}..."
      require './db/seeds/tom'
    end

    task :dev do
      puts "Seeding the database for #{Rails.env}..."
      require './db/seeds/dev'
    end

    task :backer do
      puts "Seeding the database for #{Rails.env}..."
      require './db/seeds/backer'
      create
    end
    
  end

  desc 'Delete the collections in the current RAILS_ENV database'
  task :purge do
    require './config/environment'

    puts "Purging the database for #{Rails.env}..."

    # Specifiy what models to remove
    # No!  Drop the fucking database.
   MongoMapper::connection.drop_database(MongoMapper::database.name) 

   puts 'Deleting tmp folder...'
   `rm -rf #{File.dirname(__FILE__)}/../../public/uploads/*`
  end

  desc 'Purge and seed the current RAILS_ENV database using information from db/seeds.rb'
  task :reset do
    
    puts "Resetting the database for #{Rails.env}".upcase
    Rake::Task['db:purge'].invoke
    Rake::Task['db:seed:tom'].invoke
    puts "Success!"
  end

  task :reset_dev do
    puts "making a new base user"
    Rake::Task['db:purge'].invoke
    Rake::Task['db:seed:dev'].invoke
    puts "you did it!"
  end
  
  task :fix_diaspora_handle do
    puts "fixing the people in this seed"
    require 'config/environment'
    
    people = Person.all
    
    people.each do |person|
      if person.diaspora_handle[-1, 1]=='@' && person.owner.nil? == false
        person.diaspora_handle = person.owner.diaspora_handle
        person.save
      end
    end
    puts "everything should be peachy"
  end
end
