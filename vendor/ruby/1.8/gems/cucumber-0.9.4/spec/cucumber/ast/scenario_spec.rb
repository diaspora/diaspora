require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'cucumber/step_mother'
require 'cucumber/ast'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module Ast
    describe Scenario do
      before do
        @step_mother = Cucumber::Runtime.new
        @step_mother.load_programming_language('rb')
        @dsl = Object.new
        @dsl.extend(Cucumber::RbSupport::RbDsl)

        $x = $y = nil
        @dsl.Given /y is (\d+)/ do |n|
          $y = n.to_i
        end
        @visitor = TreeWalker.new(@step_mother)
      end

      it "should skip steps when previous is not passed" do
        scenario = Scenario.new(
          background=nil,
          comment=Comment.new(""),
          tags=Tags.new(98, []), 
          line=99,
          keyword="",
          name="", 
          steps=[
            Step.new(7, "Given", "this is missing"),
            Step.new(8, "Given", "y is 5")
          ]
        )
        scenario.feature = mock('feature').as_null_object
        @visitor.visit_feature_element(scenario)

        $y.should == nil
      end

    end
  end
end
