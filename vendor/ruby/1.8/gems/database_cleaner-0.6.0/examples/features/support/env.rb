#Hilarious as it seems, this is necessary so bundle exec cucumber works for mongoid cukeage (I'm assuming mongomapper is automatically present because its a git repo)
Object.send(:remove_const, 'MongoMapper')  if defined?(::MongoMapper)

require 'rubygems'
require 'bundler'

Bundler.setup
require 'spec/expectations'
require 'ruby-debug'

DB_DIR = "#{File.dirname(__FILE__)}/../../db"

orm         = ENV['ORM']
another_orm = ENV['ANOTHER_ORM']
strategy    = ENV['STRATEGY']
multiple_db = ENV['MULTIPLE_DBS']


if orm && strategy
  $:.unshift(File.dirname(__FILE__) + '/../../../lib')
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  begin
    require "#{File.dirname(__FILE__)}/../../lib/#{orm.downcase}_models"
  rescue LoadError => e
    raise "You don't have the #{orm} ORM installed"
  end

  if another_orm
     begin
      require "#{File.dirname(__FILE__)}/../../lib/#{another_orm.downcase}_models"
    rescue LoadError => e
      raise "You don't have the #{another_orm} ORM installed"
    end
  end




  if multiple_db
    DatabaseCleaner.app_root = "#{File.dirname(__FILE__)}/../.."
    orm_sym = orm.gsub(/(.)([A-Z]+)/,'\1_\2').downcase.to_sym

    if orm_sym == :mongo_mapper
      DatabaseCleaner[ orm_sym, {:connection => 'database_cleaner_test_one'} ].strategy = strategy.to_sym
      DatabaseCleaner[ orm_sym, {:connection => 'database_cleaner_test_two'} ].strategy = strategy.to_sym
    else
      DatabaseCleaner[ orm_sym, {:connection => :one} ].strategy = strategy.to_sym
      DatabaseCleaner[ orm_sym, {:connection => :two} ].strategy = strategy.to_sym
    end

  elsif another_orm
    DatabaseCleaner[         orm.gsub(/(.)([A-Z]+)/,'\1_\2').downcase.to_sym ].strategy = strategy.to_sym
    DatabaseCleaner[ another_orm.gsub(/(.)([A-Z]+)/,'\1_\2').downcase.to_sym ].strategy = strategy.to_sym
  else
    DatabaseCleaner.strategy = strategy.to_sym
  end

else
  raise "Run 'ORM=ActiveRecord|DataMapper|MongoMapper|CouchPotato [ANOTHER_ORM=...] [MULTIPLE_DBS=true] STRATEGY=transaction|truncation cucumber examples/features'"
end
