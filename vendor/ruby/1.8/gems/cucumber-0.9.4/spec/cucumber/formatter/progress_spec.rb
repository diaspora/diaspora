require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'cucumber/formatter/progress'

module Cucumber
  module Formatter
    describe Progress do

      before(:each) do
        Term::ANSIColor.coloring = false
        @out = StringIO.new
        progress = Cucumber::Formatter::Progress.new(mock("step mother"), @out, {})
        @visitor = Cucumber::Ast::TreeWalker.new(nil, [progress])
      end
 
      describe "visiting a table cell value without a status" do
        it "should take the status from the last run step" do
          @visitor.visit_step_result('', '', nil, :failed, nil, 10, nil)
          outline_table = mock()
          outline_table.should_receive(:accept) do |visitor|
            visitor.visit_table_cell_value('value', nil)
          end
          @visitor.visit_outline_table(outline_table)

          @out.string.should == "FF"
        end
      end

      describe "visiting a table cell which is a table header" do
        it "should not output anything" do
          @visitor.visit_table_cell_value('value', :skipped_param)

          @out.string.should == ""
        end
      end

    end
  end
end
