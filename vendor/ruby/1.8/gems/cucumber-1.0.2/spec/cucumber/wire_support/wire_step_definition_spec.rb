require 'spec_helper'
require 'cucumber/wire_support/wire_language'

module Cucumber
  module WireSupport
    describe WireStepDefinition, "#invoke" do
      describe "if one of the arguments is a table" do
        it "should pass the raw table to the connection" do
          connection = mock('connection')
          step_definition = WireStepDefinition.new(connection, 'id' => 'the-id')
          expected_args = ["a","b", [["1","2"],["3","4"]]]
          connection.should_receive(:invoke).with('the-id', expected_args)
          args = ["a","b"]
          args << Cucumber::Ast::Table.new([["1","2"],["3","4"]])
          step_definition.invoke(args)
        end
      end
    end
  end
end