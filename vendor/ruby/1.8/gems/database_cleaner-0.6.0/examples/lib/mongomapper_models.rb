require 'mongo_mapper'

::MongoMapper.connection = Mongo::Connection.new('127.0.0.1')
::MongoMapper.database = 'database_cleaner_test'

class MongoMapperWidget
  include MongoMapper::Document
  key :id, Integer
  key :name, String

  class << self
    #mongomapper doesn't seem to provide this...
    def create!(*args)
      new(*args).save!
    end
  end
end

class MongoMapperWidgetUsingDatabaseOne
  include MongoMapper::Document

  connection = Mongo::Connection.new('127.0.0.1')
  set_database_name = 'database_cleaner_test_one'

  key :id, Integer
  key :name, String

  class << self
    #mongomapper doesn't seem to provide this...
    def create!(*args)
      new(*args).save!
    end
  end
end

class MongoMapperWidgetUsingDatabaseTwo
  include MongoMapper::Document

  connection = Mongo::Connection.new('127.0.0.1')
  set_database_name = 'database_cleaner_test_two'

  key :id, Integer
  key :name, String

  class << self
    #mongomapper doesn't seem to provide this...
    def create!(*args)
      new(*args).save!
    end
  end
end
