require 'spec_helper'

module RSpec
  module Mocks
    describe "OnceCounts" do
      before(:each) do
        @mock = double("test mock")
      end

      it "once fails when called once with wrong args" do
        @mock.should_receive(:random_call).once.with("a", "b", "c")
        lambda do
          @mock.random_call("d", "e", "f")
        end.should raise_error(RSpec::Mocks::MockExpectationError)
        @mock.rspec_reset
      end

      it "once fails when called twice" do
        @mock.should_receive(:random_call).once
        @mock.random_call
        @mock.random_call
        lambda do
          @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end
      
      it "once fails when not called" do
        @mock.should_receive(:random_call).once
        lambda do
          @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "once passes when called once" do
        @mock.should_receive(:random_call).once
        @mock.random_call
        @mock.rspec_verify
      end

      it "once passes when called once with specified args" do
        @mock.should_receive(:random_call).once.with("a", "b", "c")
        @mock.random_call("a", "b", "c")
        @mock.rspec_verify
      end

      it "once passes when called once with unspecified args" do
        @mock.should_receive(:random_call).once
        @mock.random_call("a", "b", "c")
        @mock.rspec_verify
      end
    end
  end
end
