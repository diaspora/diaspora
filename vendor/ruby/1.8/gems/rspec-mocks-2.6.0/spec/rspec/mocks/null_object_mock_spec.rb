require 'spec_helper'

module RSpec
  module Mocks
    describe "a double _not_ acting as a null object" do
      before(:each) do
        @double = double('non-null object')
      end

      it "says it does not respond to messages it doesn't understand" do
        @double.should_not respond_to(:foo)
      end

      it "says it responds to messages it does understand" do
        @double.stub(:foo)
        @double.should respond_to(:foo)
      end
    end

    describe "a double acting as a null object" do
      before(:each) do
        @double = double('null object').as_null_object
      end

      it "says it responds to everything" do
        @double.should respond_to(:any_message_it_gets)
      end

      it "allows explicit stubs" do
        @double.stub(:foo) { "bar" }
        @double.foo.should eq("bar")
      end

      it "allows explicit expectation" do
        @double.should_receive(:something)
        @double.something
      end

      it "fails verification when explicit exception not met" do
        lambda do
          @double.should_receive(:something)
          @double.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "ignores unexpected methods" do
        @double.random_call("a", "d", "c")
        @double.rspec_verify
      end

      it "allows expected message with different args first" do
        @double.should_receive(:message).with(:expected_arg)
        @double.message(:unexpected_arg)
        @double.message(:expected_arg)
      end

      it "allows expected message with different args second" do
        @double.should_receive(:message).with(:expected_arg)
        @double.message(:expected_arg)
        @double.message(:unexpected_arg)
      end
    end
    
    describe "#as_null_object" do
      it "sets the object to null_object" do
        obj = double('anything').as_null_object
        obj.should be_null_object
      end
    end

    describe "#null_object?" do
      it "defaults to false" do
        obj = double('anything')
        obj.should_not be_null_object
      end
    end
  end
end
