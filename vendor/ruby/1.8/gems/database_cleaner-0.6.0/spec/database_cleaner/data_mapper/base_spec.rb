require 'spec_helper'
require 'database_cleaner/data_mapper/base'
require 'database_cleaner/shared_strategy_spec'

module DatabaseCleaner
  describe DataMapper do
    it { should respond_to(:available_strategies) }
  end

  module DataMapper
    class ExampleStrategy
      include ::DatabaseCleaner::DataMapper::Base
    end

    describe ExampleStrategy do
      it_should_behave_like "a generic strategy"
      it { should respond_to(:db)  }
      it { should respond_to(:db=) }

      it "should store my desired db" do
        subject.db = :my_db
        subject.db.should == :my_db
      end

      it "should default to :default" do
        subject.db.should == :default
      end
    end
  end
end
