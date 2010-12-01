require 'spec_helper'

module RSpec
  module Mocks
    describe "PreciseCounts" do
      before(:each) do
        @mock = double("test mock")
      end

      it "fails when exactly n times method is called less than n times" do
        @mock.should_receive(:random_call).exactly(3).times
        @mock.random_call
        @mock.random_call
        lambda do
          @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "fails when exactly n times method is never called" do
        @mock.should_receive(:random_call).exactly(3).times
        lambda do
          @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "passes if exactly n times method is called exactly n times" do
        @mock.should_receive(:random_call).exactly(3).times
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.rspec_verify
      end

      it "passes multiple calls with different args and counts" do
        @mock.should_receive(:random_call).twice.with(1)
        @mock.should_receive(:random_call).once.with(2)
        @mock.random_call(1)
        @mock.random_call(2)
        @mock.random_call(1)
        @mock.rspec_verify
      end

      it "passes mutiple calls with different args" do
        @mock.should_receive(:random_call).once.with(1)
        @mock.should_receive(:random_call).once.with(2)
        @mock.random_call(1)
        @mock.random_call(2)
        @mock.rspec_verify
      end
    end
  end
end
