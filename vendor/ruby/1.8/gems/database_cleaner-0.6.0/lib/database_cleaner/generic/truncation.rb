module DatabaseCleaner
  module Generic
    module Truncation
      def self.included(base)
       base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def initialize(opts={})
          if !opts.empty? && !(opts.keys - [:only, :except]).empty?
            raise ArgumentError, "The only valid options are :only and :except. You specified #{opts.keys.join(',')}."
          end
          if opts.has_key?(:only) && opts.has_key?(:except)
            raise ArgumentError, "You may only specify either :only or :either.  Doing both doesn't really make sense does it?"
          end

          @only = opts[:only]
          @tables_to_exclude = (opts[:except] || [])
          @tables_to_exclude << migration_storage_name unless migration_storage_name.nil?
        end

        def start
          #included for compatability reasons, do nothing if you don't need to
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
  end
end
