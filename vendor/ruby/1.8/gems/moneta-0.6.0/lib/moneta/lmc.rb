begin
  require "localmemcache"
rescue LoadError
  puts "You need the localmemcache gem to use the LMC moneta store"
  exit
end

module Moneta
  class Expiration
    def initialize(hash)
      @hash = hash
    end
    
    def [](key)         @hash["#{key}__!__expiration"]          end
    def []=(key, value) @hash["#{key}__!__expiration"] = value  end
      
    def delete(key)
      key = "#{key}__!__expiration"
      value = @hash[key]
      @hash.delete(key)
      value
    end
  end
  
  class LMC
    include Defaults

    module Implementation
      def initialize(options = {})
        @hash = LocalMemCache.new(:filename => options[:filename])
        @expiration = Expiration.new(@hash)
      end    

      def [](key)         @hash[key]          end
      def []=(key, value) @hash[key] = value  end
      def clear()         @hash.clear         end

      def key?(key)
        @hash.keys.include?(key)
      end

      def delete(key)
        value = @hash[key]
        @hash.delete(key)
        value
      end      
    end
    include Implementation
    include StringExpires
   
  end
end