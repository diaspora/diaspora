require File.dirname(__FILE__) + '/../../spec_helper'
require 'mongo_mapper'
require 'database_cleaner/mongo_mapper/truncation'

MongoMapper.connection = Mongo::Connection.new('127.0.0.1')
TEST_DATABASE = 'database_cleaner_specs'
MongoMapper.database = TEST_DATABASE

class Widget
  include MongoMapper::Document
  key :name, String
end
class Gadget
  include MongoMapper::Document
  key :name, String
end


module DatabaseCleaner
  module MongoMapper

    describe Truncation do
      before(:each) do
        ::MongoMapper.connection.drop_database(TEST_DATABASE)
        #::MongoMapper.connection.db(TEST_DATABASE).collections.each {|c| c.remove }
        #::MongoMapper.database = TEST_DATABASE
      end

      def ensure_counts(expected_counts)
        # I had to add this sanity_check garbage because I was getting non-determinisc results from mongomapper at times.. 
        # very odd and disconcerting...
        sanity_check = expected_counts.delete(:sanity_check)
        begin
          expected_counts.each do |model_class, expected_count|
            model_class.count.should equal(expected_count), "#{model_class} expected to have a count of #{expected_count} but was #{model_class.count}"
          end
        rescue Spec::Expectations::ExpectationNotMetError => e
          raise !sanity_check ? e : Spec::ExpectationNotMetError::ExpectationNotMetError.new("SANITY CHECK FAILURE! This should never happen here: #{e.message}")
        end
      end

      def create_widget(attrs={})
        Widget.new({:name => 'some widget'}.merge(attrs)).save!
      end

      def create_gadget(attrs={})
        Gadget.new({:name => 'some gadget'}.merge(attrs)).save!
      end

      it "truncates all collections by default" do
        create_widget
        create_gadget
        ensure_counts(Widget => 1, Gadget => 1, :sanity_check => true)
        Truncation.new.clean
        ensure_counts(Widget => 0, Gadget => 0)
      end

      context "when collections are provided to the :only option" do
        it "only truncates the specified collections" do
          create_widget
          create_gadget
          ensure_counts(Widget => 1, Gadget => 1, :sanity_check => true)
          Truncation.new(:only => ['widgets']).clean
          ensure_counts(Widget => 0, Gadget => 1)
        end
      end

      context "when collections are provided to the :except option" do
        it "truncates all but the specified collections" do
          create_widget
          create_gadget
          ensure_counts(Widget => 1, Gadget => 1, :sanity_check => true)
          Truncation.new(:except => ['widgets']).clean
          ensure_counts(Widget => 1, Gadget => 0)
        end
      end

    end

  end
end
