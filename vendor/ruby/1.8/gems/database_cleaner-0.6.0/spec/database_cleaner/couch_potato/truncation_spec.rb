require File.dirname(__FILE__) + '/../../spec_helper'
require 'database_cleaner/couch_potato/truncation'
require 'couch_potato'

module DatabaseCleaner
  module CouchPotato

    describe Truncation do
      let(:database) { mock('database') }

      before(:each) do
        ::CouchPotato.stub!(:couchrest_database).and_return(database)
      end

      it "should re-create the database" do
        database.should_receive(:recreate!)

        Truncation.new.clean
      end

      it "should raise an error when the :only option is used" do
        running {
          Truncation.new(:only => ['document-type'])
        }.should raise_error(ArgumentError)
      end

      it "should raise an error when the :except option is used" do
        running {
          Truncation.new(:except => ['document-type'])
        }.should raise_error(ArgumentError)
      end

      it "should raise an error when invalid options are provided" do
        running {
          Truncation.new(:foo => 'bar')
        }.should raise_error(ArgumentError)
      end
    end

  end
end
