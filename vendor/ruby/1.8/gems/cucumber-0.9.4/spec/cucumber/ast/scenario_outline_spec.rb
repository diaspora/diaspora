require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'cucumber/step_mother'
require 'cucumber/ast'
require 'cucumber/core_ext/string'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module Ast
    describe ScenarioOutline do
      before do
        @step_mother = Cucumber::Runtime.new
        @step_mother.load_programming_language('rb')
        @dsl = Object.new
        @dsl.extend(Cucumber::RbSupport::RbDsl)

        @dsl.Given(/^there are (\d+) cucumbers$/) do |n|
          @initial = n.to_i
        end
        @dsl.When(/^I eat (\d+) cucumbers$/) do |n|
          @eaten = n.to_i
        end
        @dsl.Then(/^I should have (\d+) cucumbers$/) do |n|
          (@initial - @eaten).should == n.to_i
        end
        @dsl.Then(/^I should have (\d+) cucumbers in my belly$/) do |n|
          @eaten.should == n.to_i
        end

        @scenario_outline = ScenarioOutline.new(
          background=nil,
          Comment.new(""),
          Tags.new(18, []),
          19,
          "Scenario:", "My outline",
          [
            Step.new(20, 'Given', 'there are <start> cucumbers'),
            Step.new(21, 'When',  'I eat <eat> cucumbers'),
            Step.new(22, 'Then',  'I should have <left> cucumbers'),
            Step.new(23, 'And',   'I should have <eat> cucumbers in my belly')
          ],
          [
            [
              Comment.new("#Mmmm... cucumbers\n"),
              24,
              'Examples:',
              'First table',
              [
                %w{start eat left},
                %w{12 5 7},
                %w{20 6 14}
              ]
            ]
          ]

        )
      end

      it "should replace all variables and call outline once for each table row" do
        visitor = TreeWalker.new(@step_mother)
        visitor.should_receive(:visit_table_row).exactly(3).times
        visitor.visit_feature_element(@scenario_outline)
      end
    end
  end
end
