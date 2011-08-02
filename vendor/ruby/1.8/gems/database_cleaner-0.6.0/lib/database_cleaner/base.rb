module DatabaseCleaner
  class Base

    def initialize(desired_orm = nil,opts = {})
      if desired_orm == :autodetect || desired_orm.nil?
        autodetect
      else
        self.orm = desired_orm
      end
      self.db = opts[:connection] if opts.has_key? :connection
    end

    def db=(desired_db)
       self.strategy_db = desired_db
       @db = desired_db
    end

    def strategy_db=(desired_db)
      if strategy.respond_to? :db=
        strategy.db = desired_db
      elsif desired_db!= :default
        raise ArgumentError, "You must provide a strategy object that supports non default databases when you specify a database"
      end
    rescue NoStrategySetError
      #handle NoStrategySetError by doing nothing at all
      desired_db
    end

    def db
      @db || :default
    end

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
         raise ArgumentError, "You must provide a strategy object, or a symbol for a known strategy along with initialization params."
       end

       self.strategy_db = self.db

       @strategy
    end

    def strategy
      return @strategy if @strategy
      raise NoStrategySetError, "Please set a strategy with DatabaseCleaner.strategy=."
    end

    def orm=(desired_orm)
      @orm = desired_orm
    end

    def orm
      @orm || autodetect
    end

    def start
      strategy.start
    end

    def clean
      strategy.clean
    end

    alias clean! clean

    def auto_detected?
      return true unless @autodetected.nil?
    end

    #TODO make strategies directly comparable
    def ==(other)
      self.orm == other.orm && self.db == other.db && self.strategy.class == other.strategy.class
    end

    private

    def orm_module
      ::DatabaseCleaner.orm_module(orm)
    end

    def orm_strategy(strategy)
      require "database_cleaner/#{orm.to_s}/#{strategy.to_s}"
      orm_module.const_get(strategy.to_s.capitalize)
    rescue LoadError => e
      if orm_module.respond_to? :available_strategies
        raise UnknownStrategySpecified, "The '#{strategy}' strategy does not exist for the #{orm} ORM!  Available strategies: #{orm_module.available_strategies.join(', ')}"
      else
        raise UnknownStrategySpecified, "The '#{strategy}' strategy does not exist for the #{orm} ORM!"
      end
    end

    def autodetect
      @orm ||= begin
        @autodetected = true
        if defined? ::ActiveRecord
          :active_record
        elsif defined? ::DataMapper
          :data_mapper
        elsif defined? ::MongoMapper
          :mongo_mapper
        elsif defined? ::Mongoid
          :mongoid
        elsif defined? ::CouchPotato
          :couch_potato
        else
          raise NoORMDetected, "No known ORM was detected!  Is ActiveRecord, DataMapper, MongoMapper, Mongoid, or CouchPotato loaded?"
        end
      end
    end
  end
end
