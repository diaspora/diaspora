require 'database_cleaner/base'

module DatabaseCleaner

  class NoStrategySetError < StandardError;   end
  class NoORMDetected < StandardError;   end
  class UnknownStrategySpecified < ArgumentError;   end

  class << self
    def [](orm,opts = {})
      raise NoORMDetected if orm.nil?
      @connections ||= []
      cleaner = DatabaseCleaner::Base.new(orm,opts)
      connections.push cleaner
      cleaner
    end

    def app_root=(desired_root)
      @app_root = desired_root
    end

    def app_root
      @app_root || Dir.pwd
    end

    def connections
      @connections ||= [::DatabaseCleaner::Base.new]
    end

    def strategy=(stratagem)
      self.connections.each { |connect| connect.strategy = stratagem }
      remove_duplicates
    end

    def orm=(orm)
      self.connections.each { |connect| connect.orm = orm }
      remove_duplicates
    end

    def start
      self.connections.each { |connection| connection.start }
    end

    def clean
      self.connections.each { |connection| connection.clean }
    end

    alias clean! clean

    def clean_with(*args)
      self.connections.each { |connection| connection.clean_with(*args) }
    end

    alias clean_with! clean_with

    def remove_duplicates
      temp = []
      self.connections.each do |connect|
        temp.push connect unless temp.include? connect
      end
      @connections = temp
    end

    def orm_module(symbol)
      case symbol
        when :active_record
          DatabaseCleaner::ActiveRecord
        when :data_mapper
          DatabaseCleaner::DataMapper
        when :mongo
          DatabaseCleaner::Mongo
        when :mongoid
          DatabaseCleaner::Mongoid
        when :mongo_mapper
          DatabaseCleaner::MongoMapper
        when :couch_potato
          DatabaseCleaner::CouchPotato
      end
    end
  end
end
