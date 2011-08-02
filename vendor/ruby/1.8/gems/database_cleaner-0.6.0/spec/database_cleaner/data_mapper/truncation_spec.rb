require 'database_cleaner/data_mapper/truncation'
require 'database_cleaner/shared_strategy_spec'

module DatabaseCleaner
  module DataMapper
    describe Truncation do
      it_should_behave_like "a generic strategy"
      it_should_behave_like "a generic truncation strategy"
    end
  end
end
