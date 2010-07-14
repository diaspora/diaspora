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

    task :backer, :num, :password do |t, args|
      puts "Seeding the database for #{Rails.env}..."
      require 'db/seeds/backer'
      create( Integer(args.num), args.password )
    end
  end

  desc 'Delete the collections in the current RAILS_ENV database'
  task :purge do
    require 'config/environment'

    puts "Purging the database for #{Rails.env}..."

    # Specifiy what models to remove
    Post.delete_all
    Person.delete_all
    User.delete_all
    Request.delete_all
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
