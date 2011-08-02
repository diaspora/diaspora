require 'spec_helper'
require 'database_cleaner/shared_strategy_spec'
require 'database_cleaner/generic/base'

module ::DatabaseCleaner
  module Generic
    class ExampleStrategy
      include ::DatabaseCleaner::Generic::Base
    end

    describe ExampleStrategy do
      context "class methods" do
        subject { ExampleStrategy }
        its(:available_strategies) { should be_empty }
      end

      it_should_behave_like "a generic strategy"

      its(:db) { should == :default }
    end
  end
end
