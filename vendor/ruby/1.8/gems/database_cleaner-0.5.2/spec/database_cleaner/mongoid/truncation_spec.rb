require File.dirname(__FILE__) + '/../../spec_helper'
require 'mongoid'
require 'database_cleaner/mongoid/truncation'

TEST_DATABASE = 'database_cleaner_specs'
Mongoid.configure do |config|
  name = TEST_DATABASE
  config.master = Mongo::Connection.new.db(name)
end

class TestClassA
  include Mongoid::Document
  field :name
end

class TestClassB
  include Mongoid::Document
  field :name
end


module DatabaseCleaner
  module Mongoid

    describe Truncation do
      before(:each) do
        ::Mongoid.database.connection.drop_database(TEST_DATABASE)
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

      def create_testclassa(attrs={})
        TestClassA.new({:name => 'some testclassa'}.merge(attrs)).save!
      end

      def create_testclassb(attrs={})
        TestClassB.new({:name => 'some testclassb'}.merge(attrs)).save!
      end

      it "truncates all collections by default" do
        create_testclassa
        create_testclassb
        ensure_counts(TestClassA => 1, TestClassB => 1, :sanity_check => true)
        Truncation.new.clean
        ensure_counts(TestClassA => 0, TestClassB => 0)
      end

      context "when collections are provided to the :only option" do
        it "only truncates the specified collections" do
          create_testclassa
          create_testclassb
          ensure_counts(TestClassA => 1, TestClassB => 1, :sanity_check => true)
          Truncation.new(:only => ['test_class_as']).clean
          ensure_counts(TestClassA => 0, TestClassB => 1)
        end
      end

      context "when collections are provided to the :except option" do
        it "truncates all but the specified collections" do
          create_testclassa
          create_testclassb
          ensure_counts(TestClassA => 1, TestClassB => 1, :sanity_check => true)
          Truncation.new(:except => ['test_class_as']).clean
          ensure_counts(TestClassA => 1, TestClassB => 0)
        end
      end

    end

  end
end
