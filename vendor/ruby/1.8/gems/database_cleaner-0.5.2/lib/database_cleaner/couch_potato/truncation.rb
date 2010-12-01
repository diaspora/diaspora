require 'database_cleaner/truncation_base'

module DatabaseCleaner
  module CouchPotato
    class Truncation < DatabaseCleaner::TruncationBase
      def initialize(options = {})
        if options.has_key?(:only) || options.has_key?(:except)
          raise ArgumentError, "The :only and :except options are not available for use with CouchPotato/CouchDB."
        elsif !options.empty?
          raise ArgumentError, "Unsupported option. You specified #{options.keys.join(',')}."
        end
        super
      end

      def clean
        database.recreate!
      end

      private

      def database
        ::CouchPotato.couchrest_database
      end
    end
  end
end
