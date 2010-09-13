#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



namespace :db do
  desc 'Seed the current RAILS_ENV database from db/seeds.rb'
  namespace :seed do
    task :tom do
      puts "Seeding the database for #{Rails.env}..."
      require 'db/seeds/tom'
    end

    task :dev do
      puts "Seeding the database for #{Rails.env}..."
      require 'db/seeds/dev'
    end

    task :backer do
      puts "Seeding the database for #{Rails.env}..."
      require 'db/seeds/backer'
      create
    end
  end

  desc 'Delete the collections in the current RAILS_ENV database'
  task :purge do
    require 'config/environment'

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
end
