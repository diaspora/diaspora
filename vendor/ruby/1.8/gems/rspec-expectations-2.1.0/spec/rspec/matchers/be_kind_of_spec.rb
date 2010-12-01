require 'spec_helper'

module RSpec
  module Matchers
    [:be_a_kind_of, :be_kind_of].each do |method|
      describe "actual.should #{method}(expected)" do
        it "passes if actual is instance of expected class" do
          5.should send(method, Fixnum)
        end

        it "passes if actual is instance of subclass of expected class" do
          5.should send(method, Numeric)
        end

        it "fails with failure message for should unless actual is kind of expected class" do
          lambda { "foo".should send(method, Array) }.should fail_with(%Q{expected "foo" to be a kind of Array})
        end

        it "provides a description" do
          matcher = be_a_kind_of(String)
          matcher.matches?("this")
          matcher.description.should == "be a kind of String"
        end
      end
      
      describe "actual.should_not #{method}(expected)" do
        it "fails with failure message for should_not if actual is kind of expected class" do
          lambda { "foo".should_not send(method, String) }.should fail_with(%Q{expected "foo" not to be a kind of String})
        end
      end
    end
  end
end
