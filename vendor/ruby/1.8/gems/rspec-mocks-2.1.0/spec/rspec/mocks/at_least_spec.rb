require 'spec_helper'

module RSpec
  module Mocks
    describe "at_least" do
      before(:each) do
        @mock = RSpec::Mocks::Mock.new("test mock")
      end

      it "fails if method is never called" do
        @mock.should_receive(:random_call).at_least(4).times
          lambda do
        @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "fails when called less than n times" do
        @mock.should_receive(:random_call).at_least(4).times
        @mock.random_call
        @mock.random_call
        @mock.random_call
        lambda do
          @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "fails when at least once method is never called" do
        @mock.should_receive(:random_call).at_least(:once)
        lambda do
          @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "fails when at least twice method is called once" do
        @mock.should_receive(:random_call).at_least(:twice)
        @mock.random_call
        lambda do
          @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "fails when at least twice method is never called" do
        @mock.should_receive(:random_call).at_least(:twice)
        lambda do
          @mock.rspec_verify
        end.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "passes when at least n times method is called exactly n times" do
        @mock.should_receive(:random_call).at_least(4).times
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.rspec_verify
      end

      it "passes when at least n times method is called n plus 1 times" do
        @mock.should_receive(:random_call).at_least(4).times
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.rspec_verify
      end

      it "passes when at least once method is called once" do
        @mock.should_receive(:random_call).at_least(:once)
        @mock.random_call
        @mock.rspec_verify
      end

      it "passes when at least once method is called twice" do
        @mock.should_receive(:random_call).at_least(:once)
        @mock.random_call
        @mock.random_call
        @mock.rspec_verify
      end

      it "passes when at least twice method is called three times" do
        @mock.should_receive(:random_call).at_least(:twice)
        @mock.random_call
        @mock.random_call
        @mock.random_call
        @mock.rspec_verify
      end

      it "passes when at least twice method is called twice" do
        @mock.should_receive(:random_call).at_least(:twice)
        @mock.random_call
        @mock.random_call
        @mock.rspec_verify
      end
    end
  end
end
