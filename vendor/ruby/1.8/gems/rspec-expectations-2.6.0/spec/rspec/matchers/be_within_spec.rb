require 'spec_helper'

module RSpec
  module Matchers
    describe "[actual.should] be_within(delta).of(expected)" do
      it "matches when actual == expected" do
        be_within(0.5).of(5.0).matches?(5.0).should be_true
      end

      it "matches when actual < (expected + delta)" do
        be_within(0.5).of(5.0).matches?(5.49).should be_true
      end

      it "matches when actual > (expected - delta)" do
        be_within(0.5).of(5.0).matches?(4.51).should be_true
      end

      it "does not match when actual == (expected - delta)" do
        be_within(0.5).of(5.0).matches?(4.5).should be_false
      end

      it "does not match when actual < (expected - delta)" do
        be_within(0.5).of(5.0).matches?(4.49).should be_false
      end

      it "does not match when actual == (expected + delta)" do
        be_within(0.5).of(5.0).matches?(5.5).should be_false
      end

      it "does not match when actual > (expected + delta)" do
        be_within(0.5).of(5.0).matches?(5.51).should be_false
      end

      it "provides a failure message for should" do
        #given
          matcher = be_within(0.5).of(5.0)
        #when
          matcher.matches?(5.51)
        #then
          matcher.failure_message_for_should.should == "expected 5.51 to be within 0.5 of 5.0"
      end

      it "provides a failure message for should not" do
        #given
          matcher = be_within(0.5).of(5.0)
        #when
          matcher.matches?(5.49)
        #then
          matcher.failure_message_for_should_not.should == "expected 5.49 not to be within 0.5 of 5.0"
      end

      it "provides a description" do
        matcher = be_within(0.5).of(5.0)
        matcher.matches?(5.1)
        matcher.description.should == "be within 0.5 of 5.0"
      end

      it "raises an error if no expected value is given" do
        matcher = be_within(0.5)
        expect { matcher.matches?(5.1) }.to raise_error(ArgumentError, /must set an expected value using #of/)
      end
    end
  end
end
