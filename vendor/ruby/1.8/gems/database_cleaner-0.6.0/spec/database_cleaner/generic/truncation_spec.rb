require 'spec_helper'
require 'database_cleaner/generic/truncation'

module ::DatabaseCleaner
  module Generic
    class TruncationExample
      include ::DatabaseCleaner::Generic::Truncation

      def only
        @only
      end

      def except
        @tables_to_exclude
      end
    end

    class MigrationExample < TruncationExample
      def migration_storage_name
        "migration_storage_name"
      end
    end

    describe TruncationExample do
      its(:start) { expect{ subject }.to_not raise_error }
      its(:clean) { expect{ subject }.to raise_error(NotImplementedError) }

      context "private methods" do
        it { should_not respond_to(:tables_to_truncate) }
        its(:tables_to_truncate) { expect{ subject }.to raise_error(NotImplementedError) }

        it { should_not respond_to(:migration_storage_name) }
        its(:migration_storage_name) { should be_nil }
      end

      describe "initialize" do
        it { expect{ subject }.to_not raise_error }

        it "should accept a hash of options" do
          expect{ TruncationExample.new {} }.to_not raise_error
        end

        it { expect{ TruncationExample.new( { :a_random_param => "should raise ArgumentError"  } ) }.to     raise_error(ArgumentError) }
        it { expect{ TruncationExample.new( { :except => "something",:only => "something else" } ) }.to     raise_error(ArgumentError) }
        it { expect{ TruncationExample.new( { :only   => "something"                           } ) }.to_not raise_error(ArgumentError) }
        it { expect{ TruncationExample.new( { :except => "something"                           } ) }.to_not raise_error(ArgumentError) }

        context "" do
          subject { TruncationExample.new( { :only => ["something"] } ) }
          its(:only)   { should == ["something"] }
          its(:except) { should == [] }
        end

        context "" do
          subject { TruncationExample.new( { :except => ["something"] } ) }
          its(:only)   { should == nil }
          its(:except) { should include("something") }
        end

        context "" do
          subject { MigrationExample.new }
          its(:only)   { should == nil }
          its(:except) { should == ["migration_storage_name"] }
        end
      end
    end
  end
end
