#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

namespace :db do
  desc "rebuild and prepare test db"
  task :rebuild => [:drop, :create, :migrate, 'db:test:prepare']

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

    task :first_user, :username, :password, :email do |t, args|
      puts "Setting up first user in #{Rails.env} database"
      ARGS = args
      require File.dirname(__FILE__) + '/../../db/seeds/add_user'
    end

  end

  desc 'Delete the collections in the current RAILS_ENV database'
  task :purge do
    require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')

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

  desc "Purge database and then add the first user"
  task :first_user, :username, :password, :email do |t, args|
    Rake::Task['db:purge'].invoke
    Rake::Task['db:seed:first_user'].invoke(args[:username], args[:password], args[:email])
  end
  task :first_user => :environment

  desc "Add a new user to the database"
  task :add_user, :username, :password do |t, args|
    ARGS = args
    require File.dirname(__FILE__) + '/../../db/seeds/add_user'
  end
  task :add_user => :environment

  task :fix_diaspora_handle do
    puts "fixing the people in this seed"
    require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
    Person.where(:url => 'example.org').all.each{|person|
      if person.owner
        person.url = AppConfig[:pod_url]
        person.diaspora_handle = person.owner.diaspora_handle
        person.save
      end
    }
    puts "everything should be peachy"
  end

  task :move_private_key do
    require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
    User.all.each do |user|
      if user.serialized_private_key.nil?
        user.serialized_private_key = user.person.serialized_key
        user.save
        person = user.person
        person.serialized_key = nil
        person.serialized_public_key = user.encryption_key.public_key.to_s
        person.save
      end
    end
  end
end
