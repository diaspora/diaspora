require 'database_cleaner/mongo_mapper/base'
require 'database_cleaner/generic/truncation'

module DatabaseCleaner
  module MongoMapper
    class Truncation
      include ::DatabaseCleaner::MongoMapper::Base
      include ::DatabaseCleaner::Generic::Truncation

      def clean
        if @only
          collections.each { |c| c.remove if @only.include?(c.name) }
        elsif @tables_to_exclude
          collections.each { |c| c.remove unless @tables_to_exclude.include?(c.name) }
        else
          collections.each { |c| c.remove }
        end
        true
      end

      private

      def connection
        ::MongoMapper.connection
      end

      def collections
        connection.db(database).collections
      end

      def database
        ::MongoMapper.database.name
      end
    end
  end
end
