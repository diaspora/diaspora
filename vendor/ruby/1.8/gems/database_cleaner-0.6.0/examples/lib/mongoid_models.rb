require 'mongoid'

Mongoid.configure do |config|
  name = 'database_cleaner_test'
  config.master = Mongo::Connection.new.db(name)
end


#::MongoMapper.connection = Mongo::Connection.new('127.0.0.1')
#::MongoMapper.database = 'database_cleaner_test'

class MongoidWidget
  include Mongoid::Document
  field :id, :type => Integer
  field :name

  class << self
    #mongoid doesn't seem to provide this...
    def create!(*args)
      new(*args).save!
    end
  end
end

class MongoidWidgetUsingDatabaseOne
  include Mongoid::Document
  field :id, :type => Integer
  field :name

  class << self
    #mongoid doesn't seem to provide this...
    def create!(*args)
      new(*args).save!
    end
  end
end

class MongoidWidgetUsingDatabaseTwo
  include Mongoid::Document
  field :id, :type => Integer
  field :name

  class << self
    #mongoid doesn't seem to provide this...
    def create!(*args)
      new(*args).save!
    end
  end
end
