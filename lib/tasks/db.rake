#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

namespace :db do
  desc "rebuild and prepare test db"
  task :rebuild  do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:drop_integration'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    puts "seeding users, this will take awhile"
    `rake db:seed` #ghetto hax as we have active record garbage in our models
    puts "seeded!"
    Rake::Task['db:test:prepare'].invoke
  end

  namespace :integration do
    # desc 'Check for pending migrations and load the integration schema'
    task :prepare => :environment do
      abcs = ActiveRecord::Base.configurations
      envs = abcs.keys.select{ |k| k.include?("integration") }
      puts envs.inspect
      envs.each_with_index do |env, i|
        Rails.env = env
        Rake::Task.tasks.each{ |task| task.reenable }

        print "\n\n## preparing database for #{env}... "
        puts (i == 0) ? "(go get yourself a coffee)" : "(time for another coffee)"

        # do drop, schema:load_if_ruby, structure:load_if_sql, seed
        Rake::Task['db:drop'].invoke
        Rake::Task['db:setup'].invoke

        puts "db #{ActiveRecord::Base.connection.current_database} done"
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
        person.url = AppConfig.pod_uri.to_s
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
