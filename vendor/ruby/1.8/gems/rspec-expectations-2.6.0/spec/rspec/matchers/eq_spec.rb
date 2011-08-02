require 'spec_helper'

module RSpec
  module Matchers
    describe "eq" do
      it "is diffable" do
        eq(1).should be_diffable
      end

      it "matches when actual == expected" do
        1.should eq(1)
      end
      
      it "does not match when actual != expected" do
        1.should_not eq(2)
      end
      
      it "describes itself" do
        matcher = eq(1)
        matcher.matches?(1)
        matcher.description.should == "== 1"
      end
      
      it "provides message, expected and actual on #failure_message" do
        matcher = eq("1")
        matcher.matches?(1)
        matcher.failure_message_for_should.should == "\nexpected \"1\"\n     got 1\n\n(compared using ==)\n"
      end
      
      it "provides message, expected and actual on #negative_failure_message" do
        matcher = eq(1)
        matcher.matches?(1)
        matcher.failure_message_for_should_not.should == "\nexpected 1 not to equal 1\n\n(compared using ==)\n"
      end
    end
  end
end

