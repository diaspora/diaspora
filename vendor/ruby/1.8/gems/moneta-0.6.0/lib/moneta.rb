module Moneta
  module Expires
    def check_expired(key)
      if @expiration[key] && Time.now > @expiration[key]
        @expiration.delete(key)
        self.delete(key)
      end
    end

    def key?(key)
      check_expired(key)
      super
    end

    def [](key)
      check_expired(key)
      super
    end

    def fetch(key, default = nil, &blk)
      check_expired(key)
      super
    end

    def delete(key)
      check_expired(key)
      super
    end

    def update_key(key, options)
      update_options(key, options)
    end

    def store(key, value, options = {})
      ret = super(key, value)
      update_options(key, options)
      ret
    end

    private
    def update_options(key, options)
      if options[:expires_in]
        @expiration[key] = (Time.now + options[:expires_in])
      end
    end
  end

  module StringExpires
    include Expires

    def check_expired(key)
      if @expiration[key] && Time.now > Time.at(@expiration[key].to_i)
        @expiration.delete(key)
        delete(key)
      end
    end

    private
    def update_options(key, options)
      if options[:expires_in]
        @expiration[key] = (Time.now + options[:expires_in]).to_i.to_s
      end
    end
  end
  
  module Defaults
    def fetch(key, value = nil)
      value ||= block_given? ? yield(key) : default
      self[key] || value
    end
    
    def store(key, value, options = {})
      self[key] = value
    end        
  end
end
