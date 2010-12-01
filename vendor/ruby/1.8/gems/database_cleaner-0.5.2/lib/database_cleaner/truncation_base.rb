module DatabaseCleaner
  class TruncationBase

    def initialize(options = {})
      if !options.empty? && !(options.keys - [:only, :except]).empty?
        raise ArgumentError, "The only valid options are :only and :except. You specified #{options.keys.join(',')}."
      end
      if options.has_key?(:only) && options.has_key?(:except)
        raise ArgumentError, "You may only specify either :only or :either.  Doing both doesn't really make sense does it?"
      end

      @only = options[:only]
      @tables_to_exclude = (options[:except] || [])
      if migration_storage = migration_storage_name
        @tables_to_exclude << migration_storage
      end
    end

    def start
      # no-op
    end

    def clean
      raise NotImplementedError
    end


    private

    def tables_to_truncate
      raise NotImplementedError
    end

    # overwrite in subclasses
    # default implementation given because migration storage need not be present
    def migration_storage_name
      nil
    end

  end
end
