require 'spec_helper'
require 'cucumber/ast/doc_string'

module Cucumber
  module Ast
    describe DocString do
      describe "replacing arguments" do

        before(:each) do
          @ps = DocString.new("<book>\n<qty>\n")
        end
      
        it "should return a new doc_string with arguments replaced with values" do
          doc_string_with_replaced_arg = @ps.arguments_replaced({'<book>' => 'Life is elsewhere', '<qty>' => '5'})
                
          doc_string_with_replaced_arg.to_step_definition_arg.should == "Life is elsewhere\n5\n"
        end
        
        it "should not change the original doc_string" do
          doc_string_with_replaced_arg = @ps.arguments_replaced({'<book>' => 'Life is elsewhere'})
          
          @ps.to_s.should_not include("Life is elsewhere")
        end

        it "should replaced nil with empty string" do
          ps = DocString.new("'<book>'")
          doc_string_with_replaced_arg = ps.arguments_replaced({'<book>' => nil}) 
          
          doc_string_with_replaced_arg.to_step_definition_arg.should == "''"
        end

        it "should recognise when just a subset of a cell is delimited" do
          @ps.should have_text('<qty>')
        end

      end
      
    end
  end
end