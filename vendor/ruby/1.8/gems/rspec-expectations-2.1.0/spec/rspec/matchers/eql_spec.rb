require 'spec_helper'

module RSpec
  module Matchers
    describe "eql" do
      it "is diffable" do
        eql(1).should be_diffable
      end

      it "matches when actual.eql?(expected)" do
        1.should eql(1)
      end
      
      it "does not match when !actual.eql?(expected)" do
        1.should_not eql(2)
      end
      
      it "describes itself" do
        matcher = eql(1)
        matcher.matches?(1)
        matcher.description.should == "eql 1"
      end
      
      it "provides message, expected and actual on #failure_message" do
        matcher = eql("1")
        matcher.matches?(1)
        matcher.failure_message_for_should.should == "\nexpected \"1\"\n     got 1\n\n(compared using eql?)\n"
      end
      
      it "provides message, expected and actual on #negative_failure_message" do
        matcher = eql(1)
        matcher.matches?(1)
        matcher.failure_message_for_should_not.should == "\nexpected 1 not to equal 1\n\n(compared using eql?)\n"
      end
    end
  end
end
