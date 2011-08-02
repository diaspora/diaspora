require 'spec_helper'

module ExampleExpectations
  
  class ArbitraryMatcher
    def initialize(*args, &block)
      if args.last.is_a? Hash
        @expected = args.last[:expected]
      end
      @expected = block.call if block
      @block = block
    end
    
    def matches?(target)
      @target = target
      return @expected == target
    end
    
    def with(new_value)
      @expected = new_value
      self
    end
    
    def failure_message
      "expected #{@expected}, got #{@target}"
    end
    
    def negative_failure_message
      "expected not #{@expected}, got #{@target}"
    end
  end
  
  class PositiveOnlyMatcher < ArbitraryMatcher
    undef negative_failure_message rescue nil
  end
  
  def arbitrary_matcher(*args, &block)
    ArbitraryMatcher.new(*args, &block)
  end
  
  def positive_only_matcher(*args, &block)
    PositiveOnlyMatcher.new(*args, &block)
  end
  
end

module RSpec
  module Expectations
    describe PositiveExpectationHandler do
      describe "#handle_matcher" do
        it "asks the matcher if it matches" do
          matcher = mock("matcher")
          actual = Object.new
          matcher.should_receive(:matches?).with(actual).and_return(true)
          RSpec::Expectations::PositiveExpectationHandler.handle_matcher(actual, matcher)
        end
      
        it "returns the match value" do
          matcher = mock("matcher")
          actual = Object.new
          matcher.should_receive(:matches?).with(actual).and_return(:this_value)
          RSpec::Expectations::PositiveExpectationHandler.handle_matcher(actual, matcher).should == :this_value
        end
        
        it "calls failure_message_for_should if the matcher implements it" do
          matcher = mock("matcher", :failure_message_for_should => "message", :matches? => false)
          actual = Object.new
          
          ::RSpec::Expectations.should_receive(:fail_with).with("message")
          
          RSpec::Expectations::PositiveExpectationHandler.handle_matcher(actual, matcher)
        end
        
        it "calls fail if matcher.diffable?" do
          matcher = mock("matcher",
            :diffable? => true,
            :failure_message_for_should => "message",
            :matches? => false,
            :expected => [1],
            :actual   => 2
          )
          actual = Object.new
          
          ::RSpec::Expectations.should_receive(:fail_with).with("message", 1, 2)
          
          RSpec::Expectations::PositiveExpectationHandler.handle_matcher(actual, matcher)
        end
        
        it "calls failure_message if the matcher does not implement failure_message_for_should" do
          matcher = mock("matcher", :failure_message => "message", :matches? => false)
          actual = Object.new
          
          ::RSpec::Expectations.should_receive(:fail_with).with("message")
          
          RSpec::Expectations::PositiveExpectationHandler.handle_matcher(actual, matcher)
          
        end
        
        it "appends the :or message in the options hash passed to should" do
          matcher = mock("matcher", :failure_message_for_should => "message", :matches? => false)
          actual = Object.new
          
          ::RSpec::Expectations.should_receive(:fail_with).with("custom")
          
          RSpec::Expectations::PositiveExpectationHandler.handle_matcher(actual, matcher, "custom")
        end
      end
    end

    describe NegativeExpectationHandler do
      describe "#handle_matcher" do
        it "asks the matcher if it doesn't match when the matcher responds to #does_not_match?" do
          matcher = mock("matcher", :does_not_match? => true, :negative_failure_message => nil)
          actual = Object.new
          matcher.should_receive(:does_not_match?).with(actual).and_return(true)
          RSpec::Expectations::NegativeExpectationHandler.handle_matcher(actual, matcher)
        end

        it "asks the matcher if it matches when the matcher doesn't respond to #does_not_match?" do
          matcher = mock("matcher")
          actual = Object.new
          matcher.stub!(:negative_failure_message)
          matcher.should_receive(:matches?).with(actual).and_return(false)
          RSpec::Expectations::NegativeExpectationHandler.handle_matcher(actual, matcher)
        end
      
        it "returns the match value" do
          matcher = mock("matcher")
          actual = Object.new
          matcher.should_receive(:matches?).with(actual).and_return(false)
          matcher.stub!(:negative_failure_message).and_return("ignore")
          RSpec::Expectations::NegativeExpectationHandler.handle_matcher(actual, matcher).should be_false
        end

        
        it "calls failure_message_for_should_not if the matcher implements it" do
          matcher = mock("matcher", :failure_message_for_should_not => "message", :matches? => true)
          actual = Object.new
          
          ::RSpec::Expectations.should_receive(:fail_with).with("message")
          
          RSpec::Expectations::NegativeExpectationHandler.handle_matcher(actual, matcher)
          
        end
        
        it "calls negative_failure_message if the matcher does not implement failure_message_for_should_not" do
          matcher = mock("matcher", :negative_failure_message => "message", :matches? => true)
          actual = Object.new
          
          ::RSpec::Expectations.should_receive(:fail_with).with("message")
          
          RSpec::Expectations::NegativeExpectationHandler.handle_matcher(actual, matcher)
          
        end

        
        it "calls fail if matcher.diffable?" do
          matcher = mock("matcher",
            :diffable? => true,
            :failure_message_for_should_not => "message",
            :matches? => true,
            :expected => [1],
            :actual   => 2
          )
          actual = Object.new
          
          ::RSpec::Expectations.should_receive(:fail_with).with("message", 1, 2)
          
          RSpec::Expectations::NegativeExpectationHandler.handle_matcher(actual, matcher)
        end

        it "appends the :or message in the options hash passed to should" do
          matcher = mock("matcher", :failure_message_for_should_not => "message", :matches? => true)
          actual = Object.new
          
          ::RSpec::Expectations.should_receive(:fail_with).with("custom")
          
          RSpec::Expectations::NegativeExpectationHandler.handle_matcher(actual, matcher, "custom")
        end

      end
    end
    
    describe PositiveExpectationHandler do
      include ExampleExpectations
      
      it "handles submitted args" do
        5.should arbitrary_matcher(:expected => 5)
        5.should arbitrary_matcher(:expected => "wrong").with(5)
        lambda { 5.should arbitrary_matcher(:expected => 4) }.should fail_with("expected 4, got 5")
        lambda { 5.should arbitrary_matcher(:expected => 5).with(4) }.should fail_with("expected 4, got 5")
        5.should_not arbitrary_matcher(:expected => 4)
        5.should_not arbitrary_matcher(:expected => 5).with(4)
        lambda { 5.should_not arbitrary_matcher(:expected => 5) }.should fail_with("expected not 5, got 5")
        lambda { 5.should_not arbitrary_matcher(:expected => 4).with(5) }.should fail_with("expected not 5, got 5")
      end

      it "handles the submitted block" do
        5.should arbitrary_matcher { 5 }
        5.should arbitrary_matcher(:expected => 4) { 5 }
        5.should arbitrary_matcher(:expected => 4).with(5) { 3 }
      end
  
    end
  end
end
