require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'cucumber/ast/py_string'

module Cucumber
  module Ast
    describe PyString do
      describe "replacing arguments" do

        before(:each) do
          @ps = PyString.new("<book>\n<qty>\n")
        end
      
        it "should return a new py_string with arguments replaced with values" do
          py_string_with_replaced_arg = @ps.arguments_replaced({'<book>' => 'Life is elsewhere', '<qty>' => '5'})
                
          py_string_with_replaced_arg.to_step_definition_arg.should == "Life is elsewhere\n5\n"
        end
        
        it "should not change the original py_string" do
          py_string_with_replaced_arg = @ps.arguments_replaced({'<book>' => 'Life is elsewhere'})
          
          @ps.to_s.should_not include("Life is elsewhere")
        end

        it "should replaced nil with empty string" do
          ps = PyString.new("'<book>'")
          py_string_with_replaced_arg = ps.arguments_replaced({'<book>' => nil}) 
          
          py_string_with_replaced_arg.to_step_definition_arg.should == "''"
        end

        it "should recognise when just a subset of a cell is delimited" do
          @ps.should have_text('<qty>')
        end

      end
      
    end
  end
end