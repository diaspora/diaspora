require 'spec_helper'

module RSpec
  module Mocks
    describe "at_most" do
      before(:each) do
        @mock = RSpec::Mocks::Mock.new("test mock")
      end

      it "fails when at most n times method is called n plus 1 times" do
        @mock.should_receive(:random_call).at_most(4).times
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.random_call
        lambda do
          @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "fails when at most once method is called twice" do
        @mock.should_receive(:random_call).at_most(:once)
        @mock.random_call
        @mock.random_call
        lambda do
          @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "fails when at most twice method is called three times" do
        @mock.should_receive(:random_call).at_most(:twice)
        @mock.random_call
        @mock.random_call
        @mock.random_call
        lambda do
          @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "passes when at most n times method is called exactly n times" do
        @mock.should_receive(:random_call).at_most(4).times
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.rspec_verify
      end

      it "passes when at most n times method is called less than n times" do
        @mock.should_receive(:random_call).at_most(4).times
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.rspec_verify
      end

      it "passes when at most n times method is never called" do
        @mock.should_receive(:random_call).at_most(4).times
        @mock.rspec_verify
      end

      it "passes when at most once method is called once" do
        @mock.should_receive(:random_call).at_most(:once)
        @mock.random_call
        @mock.rspec_verify
      end

      it "passes when at most once method is never called" do
        @mock.should_receive(:random_call).at_most(:once)
        @mock.rspec_verify
      end

      it "passes when at most twice method is called once" do
        @mock.should_receive(:random_call).at_most(:twice)
        @mock.random_call
        @mock.rspec_verify
      end

      it "passes when at most twice method is called twice" do
        @mock.should_receive(:random_call).at_most(:twice)
        @mock.random_call
        @mock.random_call
        @mock.rspec_verify
      end

      it "passes when at most twice method is never called" do
        @mock.should_receive(:random_call).at_most(:twice)
        @mock.rspec_verify
      end
    end
  end
end
