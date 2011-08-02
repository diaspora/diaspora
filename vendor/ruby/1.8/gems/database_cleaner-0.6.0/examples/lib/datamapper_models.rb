require "dm-core"
require "dm-transactions"

#Datamapper 1.0 requires you to require dm-migrations to automigrate
require "dm-migrations"

# only to please activerecord API used in database_cleaner/examples/features/step_definitions
# yes, i know that's lazy ...

require "dm-validations"
require "dm-aggregates"

DataMapper.setup(:default, "sqlite3:#{DB_DIR}/datamapper_default.db")
DataMapper.setup(:one, "sqlite3:#{DB_DIR}/datamapper_one.db")
DataMapper.setup(:two, "sqlite3:#{DB_DIR}/datamapper_two.db")

class DataMapperWidget
  include DataMapper::Resource

  property :id,   Serial
  property :name, String
end

class DataMapperWidgetUsingDatabaseOne
  include DataMapper::Resource

  def self.default_repository_name
    :one
  end

  property :id,   Serial
  property :name, String

end

class DataMapperWidgetUsingDatabaseTwo
  include DataMapper::Resource

  def self.default_repository_name
    :two
  end

  property :id,   Serial
  property :name, String

end

DataMapperWidget.auto_migrate!
DataMapperWidgetUsingDatabaseOne.auto_migrate!
DataMapperWidgetUsingDatabaseTwo.auto_migrate!
