require 'database_cleaner/truncation_base'

module DatabaseCleaner
  module Mongoid
    class Truncation < DatabaseCleaner::TruncationBase
      def clean
        if @only
          collections.each { |c| c.remove if @only.include?(c.name) }
        else
          collections.each { |c| c.remove unless @tables_to_exclude.include?(c.name) }
        end
        true
      end

      private

      def collections
        ::Mongoid.database.collections
      end	
	
	end
  end
end
