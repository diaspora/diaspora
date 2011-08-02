begin
  require "right_aws"
rescue LoadError
  puts "You need the RightScale AWS gem to use the S3 moneta store"
  exit  
end

module Moneta
  # An S3 implementation of Moneta
  #
  # Example usage:
  #
  #   require 'rubygems'
  #   require 'moneta'
  #   require 'moneta/s3'
  #
  #   store = Moneta::S3.new(
  #     :access_key_id => 'ACCESS_KEY_ID', 
  #     :secret_access_key => 'SECRET_ACCESS_KEY', 
  #     :bucket => 'a_bucket'
  #   )
  #   store['somefile'] 
  class S3
    # Initialize the Moneta::S3 store.
    #
    # Required values passed in the options hash:
    # * <tt>:access_key_id</tt>: The access id key
    # * <tt>:secret_access_key</tt>: The secret key
    # * <tt>:bucket</tt>: The name of bucket. Will be created if it doesn't
    # exist.
    # * <tt>:multi_thread</tt>: Set to true if using threading
    def initialize(options = {})
      validate_options(options)
      s3 = RightAws::S3.new(
        options[:access_key_id], 
        options[:secret_access_key], 
        {
          :logger => logger, 
          :multi_thread => options.delete(:multi_thread) || false
        }
      )
      @bucket = s3.bucket(options.delete(:bucket), true)
    end
    
    def key?(key)
      !s3_key(key).nil?
    end
    
    alias has_key? key?
    
    def [](key)
      get(key)
    end
    
    def []=(key, value)
      store(key, value)
    end
        
    def delete(key)
      k = s3_key(key)
      if k
        value = k.get
        k.delete
        value
      end
    end
    
    # Store the key/value pair.
    # 
    # Options:
    # *<tt>:meta_headers</tt>: Meta headers passed to S3
    # *<tt>:perms</tt>: Permissions passed to S3
    # *<tt>:headers</tt>: Headers sent as part of the PUT request
    # *<tt>:expires_in</tt>: Number of seconds until expiration
    def store(key, value, options = {})
      debug "store(key=#{key}, value=#{value}, options=#{options.inspect})"
      meta_headers = meta_headers_from_options(options)
      perms = options[:perms]
      headers = options[:headers] || {}
      
      case value
      when IO
        @bucket.put(key, value.read, meta_headers, perms, headers)
      else
        @bucket.put(key, value, meta_headers, perms, headers)
      end
    end
    
    def update_key(key, options = {})
      debug "update_key(key=#{key}, options=#{options.inspect})"
      k = s3_key(key, false)
      k.save_meta(meta_headers_from_options(options)) unless k.nil?
    end
    
    def clear
      @bucket.clear
    end
    
    protected
    def logger
      @logger ||= begin
        logger = Logger.new(STDOUT)
        logger.level = Logger::FATAL
        logger
      end
    end
    
    private
    def validate_options(options)
      unless options[:access_key_id]
        raise RuntimeError, ":access_key_id is required in options"
      end
      unless options[:secret_access_key]
        raise RuntimeError, ":secret_access_key is required in options"
      end
      unless options[:bucket]
        raise RuntimeError, ":bucket is required in options"
      end
    end
    
    def get(key)
      k = s3_key(key)
      k.nil? ? nil : k.get
    end
    
    def s3_key(key, nil_if_expired=true)
      begin
        s3_key = @bucket.key(key, true)
        if s3_key.exists?
          logger.debug "[Moneta::S3] key exists: #{key}"
          if s3_key.meta_headers.has_key?('expires-at')
            expires_at = Time.parse(s3_key.meta_headers['expires-at'])
            if Time.now > expires_at && nil_if_expired
              # TODO delete the object?
              debug "key expired: #{key} (@#{s3_key.meta_headers['expires-at']})"
              return nil
            end
          end
          return s3_key
        else
          debug "key does not exist: #{key}"
        end
      rescue RightAws::AwsError => e
        debug "key does not exist: #{key}"
      end
      nil
    end
    
    def meta_headers_from_options(options={})
      meta_headers = options[:meta_headers] || {}
      if options[:expires_in]
        meta_headers['expires-at'] = (Time.now + options[:expires_in]).rfc2822
      end
      debug "setting expires-at: #{meta_headers['expires-at']}"
      meta_headers
    end
    
    def debug(message)
      logger.debug "[Moneta::S3] #{message}"
    end
  end
end
