begin
  require "memcached"
rescue LoadError
  require "memcache"
rescue LoadError
  puts "You need the memcache gem to use the Memcache moneta store"
  exit
end

module Moneta
  class Memcache
    include Defaults
    
    def initialize(options = {})
      @cache = MemCache.new(options.delete(:server), options)
    end

    def key?(key)
      !self[key].nil?
    end

    alias has_key? key?

    def [](key)
      @cache.get(key)
    end

    def []=(key, value)
      store(key, value)
    end

    def delete(key)
      value = self[key]
      @cache.delete(key) if value
      value
    end

    def store(key, value, options = {})
      args = [key, value, options[:expires_in]].compact
      @cache.set(*args)
    end

    def update_key(key, options = {})
      val = self[key]
      self.store(key, val, options)
    end

    def clear
      @cache.flush_all
    end
  end
end
