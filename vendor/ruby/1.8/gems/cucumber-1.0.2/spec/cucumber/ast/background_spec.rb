require 'spec_helper'
require 'cucumber/ast'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module Ast
    describe Background do

      before do
        extend(Cucumber::RbSupport::RbDsl)
        @runtime = Cucumber::Runtime.new
        @rb = @runtime.load_programming_language('rb')

        $x = $y = nil
        Before do
          $x = 2
        end
        Given /y is (\d+)/ do |n|
          $y = $x * n.to_i
        end

        @visitor = TreeWalker.new(@runtime)

        @feature = mock('feature', :visit? => true).as_null_object
      end

      it "should execute Before blocks before background steps" do
        background = Background.new(
          comment=Comment.new(''),
          line=2,
          keyword="", 
          title="",
          description="",
          steps=[
            Step.new(7, "Given", "y is 5")
          ])

        scenario = Scenario.new(
          background,
          comment=Comment.new(""), 
          tags=Tags.new(98,[]),
          line=99,
          keyword="", 
          title="",
          description="",
          steps=[]
        )
        background.feature = @feature
        @visitor.visit_background(background)
        $x.should == 2
        $y.should == 10
      end

      describe "should respond to #name" do
        it "with a value" do
          background = Background.new(
            comment=Comment.new(''),
            line=2,
            keyword="",
            title="background name",
            description="",
            steps=[])
          lambda{ background.name }.should_not raise_error
          background.name.should == 'background name'
        end
        it "without a value" do
          background = Background.new(
            comment=Comment.new(''),
            line=2,
            keyword="",
            title="",
            description="",
            steps=[])
        lambda{ background.name }.should_not raise_error
        end
      end

      describe "failures in a Before hook" do

        before do
          Before do
            raise Exception, "Exception from Before hook"
          end
        end

        it "should state that the background has failed" do
          # Assign
          background = Background.new(
            comment=Comment.new(''),
            line=2,
            keyword="",
            title="",
            description="",
            steps=[
              Step.new(7, "Given", "y is 5")
            ])
          background.feature = @feature

          # Expect
          @visitor.should_receive( :visit_exception ) do |exception, status|
            exception.should be_instance_of( Exception )
            exception.message.should == "Exception from Before hook"
            status.should == :failed
           end

          # Assert
          lambda{ @visitor.visit_background(background) }.should_not raise_error
          background.should be_failed
        end

      end
    end
    
  end
end
