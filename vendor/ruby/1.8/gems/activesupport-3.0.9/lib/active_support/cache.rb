require 'benchmark'
require 'zlib'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/benchmark'
require 'active_support/core_ext/exception'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/numeric/bytes'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/string/inflections'

module ActiveSupport
  # See ActiveSupport::Cache::Store for documentation.
  module Cache
    autoload :FileStore, 'active_support/cache/file_store'
    autoload :MemoryStore, 'active_support/cache/memory_store'
    autoload :MemCacheStore, 'active_support/cache/mem_cache_store'
    autoload :SynchronizedMemoryStore, 'active_support/cache/synchronized_memory_store'
    autoload :CompressedMemCacheStore, 'active_support/cache/compressed_mem_cache_store'

    # These options mean something to all cache implementations. Individual cache
    # implementations may support additional options.
    UNIVERSAL_OPTIONS = [:namespace, :compress, :compress_threshold, :expires_in, :race_condition_ttl]

    module Strategy
      autoload :LocalCache, 'active_support/cache/strategy/local_cache'
    end

    # Creates a new CacheStore object according to the given options.
    #
    # If no arguments are passed to this method, then a new
    # ActiveSupport::Cache::MemoryStore object will be returned.
    #
    # If you pass a Symbol as the first argument, then a corresponding cache
    # store class under the ActiveSupport::Cache namespace will be created.
    # For example:
    #
    #   ActiveSupport::Cache.lookup_store(:memory_store)
    #   # => returns a new ActiveSupport::Cache::MemoryStore object
    #
    #   ActiveSupport::Cache.lookup_store(:mem_cache_store)
    #   # => returns a new ActiveSupport::Cache::MemCacheStore object
    #
    # Any additional arguments will be passed to the corresponding cache store
    # class's constructor:
    #
    #   ActiveSupport::Cache.lookup_store(:file_store, "/tmp/cache")
    #   # => same as: ActiveSupport::Cache::FileStore.new("/tmp/cache")
    #
    # If the first argument is not a Symbol, then it will simply be returned:
    #
    #   ActiveSupport::Cache.lookup_store(MyOwnCacheStore.new)
    #   # => returns MyOwnCacheStore.new
    def self.lookup_store(*store_option)
      store, *parameters = *Array.wrap(store_option).flatten

      case store
      when Symbol
        store_class_name = store.to_s.camelize
        store_class =
          begin
            require "active_support/cache/#{store}"
          rescue LoadError => e
            raise "Could not find cache store adapter for #{store} (#{e})"
          else
            ActiveSupport::Cache.const_get(store_class_name)
          end
        store_class.new(*parameters)
      when nil
        ActiveSupport::Cache::MemoryStore.new
      else
        store
      end
    end

    def self.expand_cache_key(key, namespace = nil)
      expanded_cache_key = namespace ? "#{namespace}/" : ""

      prefix = ENV["RAILS_CACHE_ID"] || ENV["RAILS_APP_VERSION"]
      if prefix
        expanded_cache_key << "#{prefix}/"
      end

      expanded_cache_key <<
        if key.respond_to?(:cache_key)
          key.cache_key
        elsif key.is_a?(Array)
          if key.size > 1
            key.collect { |element| expand_cache_key(element) }.to_param
          else
            key.first.to_param
          end
        elsif key
          key.to_param
        end.to_s

      expanded_cache_key
    end

    # An abstract cache store class. There are multiple cache store
    # implementations, each having its own additional features. See the classes
    # under the ActiveSupport::Cache module, e.g.
    # ActiveSupport::Cache::MemCacheStore. MemCacheStore is currently the most
    # popular cache store for large production websites.
    #
    # Some implementations may not support all methods beyond the basic cache
    # methods of +fetch+, +write+, +read+, +exist?+, and +delete+.
    #
    # ActiveSupport::Cache::Store can store any serializable Ruby object.
    #
    #   cache = ActiveSupport::Cache::MemoryStore.new
    #
    #   cache.read("city")   # => nil
    #   cache.write("city", "Duckburgh")
    #   cache.read("city")   # => "Duckburgh"
    #
    # Keys are always translated into Strings and are case sensitive. When an
    # object is specified as a key, its +cache_key+ method will be called if it
    # is defined. Otherwise, the +to_param+ method will be called. Hashes and
    # Arrays can be used as keys. The elements will be delimited by slashes
    # and Hashes elements will be sorted by key so they are consistent.
    #
    #   cache.read("city") == cache.read(:city)   # => true
    #
    # Nil values can be cached.
    #
    # If your cache is on a shared infrastructure, you can define a namespace for
    # your cache entries. If a namespace is defined, it will be prefixed on to every
    # key. The namespace can be either a static value or a Proc. If it is a Proc, it
    # will be invoked when each key is evaluated so that you can use application logic
    # to invalidate keys.
    #
    #   cache.namespace = lambda { @last_mod_time }  # Set the namespace to a variable
    #   @last_mod_time = Time.now  # Invalidate the entire cache by changing namespace
    #
    #
    # Caches can also store values in a compressed format to save space and reduce
    # time spent sending data. Since there is some overhead, values must be large
    # enough to warrant compression. To turn on compression either pass
    # <tt>:compress => true</tt> in the initializer or to +fetch+ or +write+.
    # To specify the threshold at which to compress values, set
    # <tt>:compress_threshold</tt>. The default threshold is 32K.
    class Store

      cattr_accessor :logger, :instance_writer => true

      attr_reader :silence, :options
      alias :silence? :silence

      # Create a new cache. The options will be passed to any write method calls except
      # for :namespace which can be used to set the global namespace for the cache.
      def initialize (options = nil)
        @options = options ? options.dup : {}
      end

      # Silence the logger.
      def silence!
        @silence = true
        self
      end

      # Silence the logger within a block.
      def mute
        previous_silence, @silence = defined?(@silence) && @silence, true
        yield
      ensure
        @silence = previous_silence
      end

      # Set to true if cache stores should be instrumented. Default is false.
      def self.instrument=(boolean)
        Thread.current[:instrument_cache_store] = boolean
      end

      def self.instrument
        Thread.current[:instrument_cache_store] || false
      end

      # Fetches data from the cache, using the given key. If there is data in
      # the cache with the given key, then that data is returned.
      #
      # If there is no such data in the cache (a cache miss occurred),
      # then nil will be returned. However, if a block has been passed, then
      # that block will be run in the event of a cache miss. The return value
      # of the block will be written to the cache under the given cache key,
      # and that return value will be returned.
      #
      #   cache.write("today", "Monday")
      #   cache.fetch("today")  # => "Monday"
      #
      #   cache.fetch("city")   # => nil
      #   cache.fetch("city") do
      #     "Duckburgh"
      #   end
      #   cache.fetch("city")   # => "Duckburgh"
      #
      # You may also specify additional options via the +options+ argument.
      # Setting <tt>:force => true</tt> will force a cache miss:
      #
      #   cache.write("today", "Monday")
      #   cache.fetch("today", :force => true)  # => nil
      #
      # Setting <tt>:compress</tt> will store a large cache entry set by the call
      # in a compressed format.
      #
      #
      # Setting <tt>:expires_in</tt> will set an expiration time on the cache. All caches
      # support auto expiring content after a specified number of seconds. This value can
      # be specified as an option to the construction in which call all entries will be
      # affected. Or it can be supplied to the +fetch+ or +write+ method for just one entry.
      #
      #   cache = ActiveSupport::Cache::MemoryStore.new(:expires_in => 5.minutes)
      #   cache.write(key, value, :expires_in => 1.minute)  # Set a lower value for one entry
      #
      # Setting <tt>:race_condition_ttl</tt> is very useful in situations where a cache entry
      # is used very frequently and is under heavy load. If a cache expires and due to heavy load
      # seven different processes will try to read data natively and then they all will try to
      # write to cache. To avoid that case the first process to find an expired cache entry will
      # bump the cache expiration time by the value set in <tt>:race_condition_ttl</tt>. Yes
      # this process is extending the time for a stale value by another few seconds. Because
      # of extended life of the previous cache, other processes will continue to use slightly
      # stale data for a just a big longer. In the meantime that first process will go ahead
      # and will write into cache the new value. After that all the processes will start
      # getting new value. The key is to keep <tt>:race_condition_ttl</tt> small.
      #
      # If the process regenerating the entry errors out, the entry will be regenerated
      # after the specified number of seconds. Also note that the life of stale cache is
      # extended only if it expired recently. Otherwise a new value is generated and
      # <tt>:race_condition_ttl</tt> does not play any role.
      #
      #   # Set all values to expire after one minute.
      #   cache = ActiveSupport::Cache::MemoryCache.new(:expires_in => 1.minute)
      #
      #   cache.write("foo", "original value")
      #   val_1 = nil
      #   val_2 = nil
      #   sleep 60
      #
      #   Thread.new do
      #     val_1 = cache.fetch("foo", :race_condition_ttl => 10) do
      #       sleep 1
      #       "new value 1"
      #     end
      #   end
      #
      #   Thread.new do
      #     val_2 = cache.fetch("foo", :race_condition_ttl => 10) do
      #       "new value 2"
      #     end
      #   end
      #
      #   # val_1 => "new value 1"
      #   # val_2 => "original value"
      #   # sleep 10 # First thread extend the life of cache by another 10 seconds
      #   # cache.fetch("foo") => "new value 1"
      #
      # Other options will be handled by the specific cache store implementation.
      # Internally, #fetch calls #read_entry, and calls #write_entry on a cache miss.
      # +options+ will be passed to the #read and #write calls.
      #
      # For example, MemCacheStore's #write method supports the +:raw+
      # option, which tells the memcached server to store all values as strings.
      # We can use this option with #fetch too:
      #
      #   cache = ActiveSupport::Cache::MemCacheStore.new
      #   cache.fetch("foo", :force => true, :raw => true) do
      #     :bar
      #   end
      #   cache.fetch("foo")  # => "bar"
      def fetch(name, options = nil)
        if block_given?
          options = merged_options(options)
          key = namespaced_key(name, options)
          unless options[:force]
            entry = instrument(:read, name, options) do |payload|
              payload[:super_operation] = :fetch if payload
              read_entry(key, options)
            end
          end
          if entry && entry.expired?
            race_ttl = options[:race_condition_ttl].to_f
            if race_ttl and Time.now.to_f - entry.expires_at <= race_ttl
              entry.expires_at = Time.now + race_ttl
              write_entry(key, entry, :expires_in => race_ttl * 2)
            else
              delete_entry(key, options)
            end
            entry = nil
          end

          if entry
            instrument(:fetch_hit, name, options) { |payload| }
            entry.value
          else
            result = instrument(:generate, name, options) do |payload|
              yield
            end
            write(name, result, options)
            result
          end
        else
          read(name, options)
        end
      end

      # Fetches data from the cache, using the given key. If there is data in
      # the cache with the given key, then that data is returned. Otherwise,
      # nil is returned.
      #
      # Options are passed to the underlying cache implementation.
      def read(name, options = nil)
        options = merged_options(options)
        key = namespaced_key(name, options)
        instrument(:read, name, options) do |payload|
          entry = read_entry(key, options)
          if entry
            if entry.expired?
              delete_entry(key, options)
              payload[:hit] = false if payload
              nil
            else
              payload[:hit] = true if payload
              entry.value
            end
          else
            payload[:hit] = false if payload
            nil
          end
        end
      end

      # Read multiple values at once from the cache. Options can be passed
      # in the last argument.
      #
      # Some cache implementation may optimize this method.
      #
      # Returns a hash mapping the names provided to the values found.
      def read_multi(*names)
        options = names.extract_options!
        options = merged_options(options)
        results = {}
        names.each do |name|
          key = namespaced_key(name, options)
          entry = read_entry(key, options)
          if entry
            if entry.expired?
              delete_entry(key)
            else
              results[name] = entry.value
            end
          end
        end
        results
      end

      # Writes the value to the cache, with the key.
      #
      # Options are passed to the underlying cache implementation.
      def write(name, value, options = nil)
        options = merged_options(options)
        instrument(:write, name, options) do |payload|
          entry = Entry.new(value, options)
          write_entry(namespaced_key(name, options), entry, options)
        end
      end

      # Deletes an entry in the cache. Returns +true+ if an entry is deleted.
      #
      # Options are passed to the underlying cache implementation.
      def delete(name, options = nil)
        options = merged_options(options)
        instrument(:delete, name) do |payload|
          delete_entry(namespaced_key(name, options), options)
        end
      end

      # Return true if the cache contains an entry for the given key.
      #
      # Options are passed to the underlying cache implementation.
      def exist?(name, options = nil)
        options = merged_options(options)
        instrument(:exist?, name) do |payload|
          entry = read_entry(namespaced_key(name, options), options)
          if entry && !entry.expired?
            true
          else
            false
          end
        end
      end

      # Delete all entries with keys matching the pattern.
      #
      # Options are passed to the underlying cache implementation.
      #
      # All implementations may not support this method.
      def delete_matched(matcher, options = nil)
        raise NotImplementedError.new("#{self.class.name} does not support delete_matched")
      end

      # Increment an integer value in the cache.
      #
      # Options are passed to the underlying cache implementation.
      #
      # All implementations may not support this method.
      def increment(name, amount = 1, options = nil)
        raise NotImplementedError.new("#{self.class.name} does not support increment")
      end

      # Increment an integer value in the cache.
      #
      # Options are passed to the underlying cache implementation.
      #
      # All implementations may not support this method.
      def decrement(name, amount = 1, options = nil)
        raise NotImplementedError.new("#{self.class.name} does not support decrement")
      end

      # Cleanup the cache by removing expired entries.
      #
      # Options are passed to the underlying cache implementation.
      #
      # All implementations may not support this method.
      def cleanup(options = nil)
        raise NotImplementedError.new("#{self.class.name} does not support cleanup")
      end

      # Clear the entire cache. Be careful with this method since it could
      # affect other processes if shared cache is being used.
      #
      # Options are passed to the underlying cache implementation.
      #
      # All implementations may not support this method.
      def clear(options = nil)
        raise NotImplementedError.new("#{self.class.name} does not support clear")
      end

      protected
        # Add the namespace defined in the options to a pattern designed to match keys.
        # Implementations that support delete_matched should call this method to translate
        # a pattern that matches names into one that matches namespaced keys.
        def key_matcher(pattern, options)
          prefix = options[:namespace].is_a?(Proc) ? options[:namespace].call : options[:namespace]
          if prefix
            source = pattern.source
            if source.start_with?('^')
              source = source[1, source.length]
            else
              source = ".*#{source[0, source.length]}"
            end
            Regexp.new("^#{Regexp.escape(prefix)}:#{source}", pattern.options)
          else
            pattern
          end
        end

        # Read an entry from the cache implementation. Subclasses must implement this method.
        def read_entry(key, options) # :nodoc:
          raise NotImplementedError.new
        end

        # Write an entry to the cache implementation. Subclasses must implement this method.
        def write_entry(key, entry, options) # :nodoc:
          raise NotImplementedError.new
        end

        # Delete an entry from the cache implementation. Subclasses must implement this method.
        def delete_entry(key, options) # :nodoc:
          raise NotImplementedError.new
        end

      private
        # Merge the default options with ones specific to a method call.
        def merged_options(call_options) # :nodoc:
          if call_options
            options.merge(call_options)
          else
            options.dup
          end
        end

        # Expand key to be a consistent string value. Invoke +cache_key+ if
        # object responds to +cache_key+. Otherwise, to_param method will be
        # called. If the key is a Hash, then keys will be sorted alphabetically.
        def expanded_key(key) # :nodoc:
          if key.respond_to?(:cache_key)
            key = key.cache_key.to_s
          elsif key.is_a?(Array)
            if key.size > 1
              key.collect{|element| expanded_key(element)}.to_param
            else
              key.first.to_param
            end
          elsif key.is_a?(Hash)
            key = key.to_a.sort{|a,b| a.first.to_s <=> b.first.to_s}.collect{|k,v| "#{k}=#{v}"}.to_param
          else
            key = key.to_param
          end
        end

        # Prefix a key with the namespace. Namespace and key will be delimited with a colon.
        def namespaced_key(key, options)
          key = expanded_key(key)
          namespace = options[:namespace] if options
          prefix = namespace.is_a?(Proc) ? namespace.call : namespace
          key = "#{prefix}:#{key}" if prefix
          key
        end

        def instrument(operation, key, options = nil)
          log(operation, key, options)

          if self.class.instrument
            payload = { :key => key }
            payload.merge!(options) if options.is_a?(Hash)
            ActiveSupport::Notifications.instrument("cache_#{operation}.active_support", payload){ yield(payload) }
          else
            yield(nil)
          end
        end

        def log(operation, key, options = nil)
          return unless logger && logger.debug? && !silence?
          logger.debug("Cache #{operation}: #{key}#{options.blank? ? "" : " (#{options.inspect})"}")
        end
    end

    # Entry that is put into caches. It supports expiration time on entries and can compress values
    # to save space in the cache.
    class Entry
      attr_reader :created_at, :expires_in

      DEFAULT_COMPRESS_LIMIT = 16.kilobytes

      class << self
        # Create an entry with internal attributes set. This method is intended to be
        # used by implementations that store cache entries in a native format instead
        # of as serialized Ruby objects.
        def create (raw_value, created_at, options = {})
          entry = new(nil)
          entry.instance_variable_set(:@value, raw_value)
          entry.instance_variable_set(:@created_at, created_at.to_f)
          entry.instance_variable_set(:@compressed, !!options[:compressed])
          entry.instance_variable_set(:@expires_in, options[:expires_in])
          entry
        end
      end

      # Create a new cache entry for the specified value. Options supported are
      # +:compress+, +:compress_threshold+, and +:expires_in+.
      def initialize(value, options = {})
        @compressed = false
        @expires_in = options[:expires_in]
        @expires_in = @expires_in.to_f if @expires_in
        @created_at = Time.now.to_f
        if value
          if should_compress?(value, options)
            @value = Zlib::Deflate.deflate(Marshal.dump(value))
            @compressed = true
          else
            @value = value
          end
        else
          @value = nil
        end
      end

      # Get the raw value. This value may be serialized and compressed.
      def raw_value
        @value
      end

      # Get the value stored in the cache.
      def value
        if @value
          val = compressed? ? Marshal.load(Zlib::Inflate.inflate(@value)) : @value
          unless val.frozen?
            val.freeze rescue nil
          end
          val
        end
      end

      def compressed?
        @compressed
      end

      # Check if the entry is expired. The +expires_in+ parameter can override the
      # value set when the entry was created.
      def expired?
        if @expires_in && @created_at + @expires_in <= Time.now.to_f
          true
        else
          false
        end
      end

      # Set a new time when the entry will expire.
      def expires_at=(time)
        if time
          @expires_in = time.to_f - @created_at
        else
          @expires_in = nil
        end
      end

      # Seconds since the epoch when the entry will expire.
      def expires_at
        @expires_in ? @created_at + @expires_in : nil
      end

      # Returns the size of the cached value. This could be less than value.size
      # if the data is compressed.
      def size
        if @value.nil?
          0
        elsif @value.respond_to?(:bytesize)
          @value.bytesize
        else
          Marshal.dump(@value).bytesize
        end
      end

      private
        def should_compress?(value, options)
          if options[:compress] && value
            unless value.is_a?(Numeric)
              compress_threshold = options[:compress_threshold] || DEFAULT_COMPRESS_LIMIT
              serialized_value = value.is_a?(String) ? value : Marshal.dump(value)
              return true if serialized_value.size >= compress_threshold
            end
          end
          false
        end
    end
  end
end
