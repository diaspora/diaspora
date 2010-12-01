begin
  require "mongo"
rescue LoadError
  puts "You need the mongo gem to use the MongoDB moneta store"
  exit
end

module Moneta
  class MongoDB
    include Defaults
    
    def initialize(options = {})
      options = {
        :host => ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost',
        :port => ENV['MONGO_RUBY_DRIVER_PORT'] || XGen::Mongo::Driver::Mongo::DEFAULT_PORT,
        :db => 'cache',
        :collection => 'cache'
      }.update(options)
      conn = XGen::Mongo::Driver::Mongo.new(options[:host], options[:port])
      @cache = conn.db(options[:db]).collection(options[:collection])
    end

    def key?(key)
      !!self[key]
    end

    def [](key)
      res = @cache.find_first('_id' => key)
      res = nil if res && res['expires'] && Time.now > res['expires']
      res && res['data']
    end

    def []=(key, value)
      store(key, value)
    end

    def delete(key)
      value = self[key]
      @cache.remove('_id' => key) if value
      value
    end

    def store(key, value, options = {})
      exp = options[:expires_in] ? (Time.now + options[:expires_in]) : nil
      @cache.repsert({ '_id' => key }, { '_id' => key, 'data' => value, 'expires' => exp })
    end

    def update_key(key, options = {})
      val = self[key]
      self.store(key, val, options)
    end

    def clear
      @cache.clear
    end
  end
end

