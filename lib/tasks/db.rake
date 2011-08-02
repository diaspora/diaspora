#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

namespace :db do
  desc "rebuild and prepare test db"
  task :rebuild => [:drop, :drop_integration, :create, :migrate, :seed, 'db:test:prepare']

  namespace :integration do
    # desc 'Check for pending migrations and load the integration schema'
    task :prepare => :environment do
      abcs = ActiveRecord::Base.configurations
      envs = abcs.keys.select{ |k| k.include?("integration") }
      envs.each do |env|
        ActiveRecord::Base.establish_connection(env)
        ActiveRecord::Base.connection.drop_database(abcs[env]["database"])
        ActiveRecord::Base.connection.create_database(abcs[env]["database"])
        ActiveRecord::Base.establish_connection(env)
        ActiveRecord::Migrator.migrate("db/migrate", nil)
      end
    end
  end

  desc 'Delete the collections in the current RAILS_ENV database'
  task :purge do
    require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')

    puts "Purging the database for #{Rails.env}..."

    Rake::Task['db:rebuild'].invoke

   puts 'Deleting tmp folder...'
   `rm -rf #{File.dirname(__FILE__)}/../../public/uploads/*`
  end

  desc 'Purge and seed the current RAILS_ENV database using information from db/seeds.rb'
  task :reset do
    puts "Resetting the database for #{Rails.env}".upcase
    Rake::Task['db:purge'].invoke
    Rake::Task['db:seed'].invoke
    puts "Success!"
  end

  task :drop_integration do
    ActiveRecord::Base.configurations.keys.select{ |k|
      k.include?("integration")
    }.each{ |k|
      drop_database ActiveRecord::Base.configurations[k] rescue Mysql2::Error
    }
  end

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
