begin
  require "redis"
rescue LoadError
  puts "You need the redis gem to use the Redis store"
  exit
end

module Moneta
  class Redis
    include Defaults
    
    def initialize(options = {})
      @cache = ::Redis.new(options)
    end
    
    def key?(key)
      !@cache[key].nil?
    end
    
    alias has_key? key?
    
    def [](key)
      @cache.get(key)
    end
    
    def []=(key, value)
      store(key, value)
    end
        
    def delete(key)
      value = @cache[key]
      @cache.delete(key) if value
      value
    end
    
    def store(key, value, options = {})
      @cache.set(key, value, options[:expires_in])
    end
    
    def update_key(key, options = {})
      val = @cache[key]
      self.store(key, val, options)
    end
    
    def clear
      @cache.flush_db
    end
  end
end
