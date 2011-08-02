require 'database_cleaner/generic/base'
module DatabaseCleaner
  module MongoMapper
    def self.available_strategies
      %w[truncation]
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      def db=(desired_db)
        @db = desired_db
      end

      def db
        @db || :default
      end
    end
  end
end
