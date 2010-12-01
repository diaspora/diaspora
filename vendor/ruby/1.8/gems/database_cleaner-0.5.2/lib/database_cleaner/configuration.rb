module DatabaseCleaner

  class NoStrategySetError < StandardError;   end
  class NoORMDetected < StandardError;   end
  class UnknownStrategySpecified < ArgumentError;   end

  module ActiveRecord
    def self.available_strategies
      %w[truncation transaction]
    end
  end

  module DataMapper
    def self.available_strategies
      %w[truncation transaction]
    end
  end
  

  module MongoMapper
    def self.available_strategies
      %w[truncation]
    end
  end

  module Mongoid
    def self.available_strategies
      %w[truncation]
    end
  end

  module CouchPotato
    def self.available_strategies
      %w[truncation]
    end
  end

  class << self

    def create_strategy(*args)
      strategy, *strategy_args = args
      orm_strategy(strategy).new(*strategy_args)
    end

    def clean_with(*args)
      strategy = create_strategy(*args)
      strategy.clean
      strategy
    end

    alias clean_with! clean_with

    def strategy=(args)
      strategy, *strategy_args = args
       if strategy.is_a?(Symbol)
          @strategy = create_strategy(*args)
       elsif strategy_args.empty?
         @strategy = strategy
       else
         raise ArgumentError, "You must provide a strategy object, or a symbol for a know strategy along with initialization params."
       end
    end

    def orm=(orm_string)
      @orm = orm_string
    end

    def start
      strategy.start
    end

    def clean
      strategy.clean
    end

    alias clean! clean

    private

    def strategy
      return @strategy if @strategy
      raise NoStrategySetError, "Please set a strategy with DatabaseCleaner.strategy=."
    end

    def orm_strategy(strategy)
  		require "database_cleaner/#{orm}/#{strategy}"
      orm_module.const_get(strategy.to_s.capitalize)
    rescue LoadError => e
      raise UnknownStrategySpecified, "The '#{strategy}' strategy does not exist for the #{orm} ORM!  Available strategies: #{orm_module.available_strategies.join(', ')}"
    end


    def orm
      @orm ||=begin
        if defined? ::ActiveRecord
          'active_record'
        elsif defined? ::DataMapper
          'data_mapper'
        elsif defined? ::MongoMapper
          'mongo_mapper'
        elsif defined? ::Mongoid
          'mongoid'
        elsif defined? ::CouchPotato
          'couch_potato'
        else
          raise NoORMDetected, "No known ORM was detected!  Is ActiveRecord, DataMapper, MongoMapper, Mongoid, or CouchPotato loaded?"
        end
      end
    end


    def orm_module
      case orm
      when 'active_record'
        DatabaseCleaner::ActiveRecord
      when 'data_mapper'
        DatabaseCleaner::DataMapper
      when 'mongo_mapper'
        DatabaseCleaner::MongoMapper
      when 'mongoid'
        DatabaseCleaner::Mongoid
      when 'couch_potato'
        DatabaseCleaner::CouchPotato
      end
    end

  end

end
