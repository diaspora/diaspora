#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

namespace :db do
  desc 'Seed the current RAILS_ENV database from db/seeds.rb'
  namespace :seed do
    task :tom do
      puts "Seeding the database for #{Rails.env}..."
      require File.dirname(__FILE__) + '/../../db/seeds/tom'
    end

    task :dev do
      puts "Seeding the database for #{Rails.env}..."
      require File.dirname(__FILE__) + '/../../db/seeds/dev'
    end

    task :backer do
      puts "Seeding the database for #{Rails.env}..."
      require File.dirname(__FILE__) + '/../../db/seeds/backer'
      create
    end

  end

  desc 'Delete the collections in the current RAILS_ENV database'
  task :purge do
    require File.dirname(__FILE__) + '/../../config/environment'

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
    Rake::Task['db:seed:dev'].invoke
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
    require File.dirname(__FILE__) + '/../../config/environment'
    Person.where(:url => 'example.org').all.each{|person|
      if person.owner
        person.url = APP_CONFIG[:pod_url]
        person.diaspora_handle = person.owner.diaspora_handle
        person.save
      end
    }
    puts "everything should be peachy"
  end

  task :move_private_key do
    User.all.each do |user|
      if user.private_key.nil?
        user.private_key = user.person.serialized_key
        user.save
        person = user.person
        person.serialized_key = nil
        person.serialized_public_key = user.encryption_key.public_key
        person.save
      end
    end
  end
end
