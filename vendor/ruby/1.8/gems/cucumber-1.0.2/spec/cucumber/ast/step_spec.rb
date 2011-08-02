require 'spec_helper'
require 'cucumber/step_mother'
require 'cucumber/ast'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    describe Step do
      it "should replace arguments in name" do
        step = Step.new(1, 'Given', 'a <color> cucumber')

        invocation_table = Table.new([
          %w{color taste},
          %w{green juicy}
        ])
        cells = invocation_table.cells_rows[1]
        step_invocation = step.step_invocation_from_cells(cells)
        
        step_invocation.name.should == 'a green cucumber'
      end

      it "should use empty string for the replacement of arguments in name when replace value is nil" do
        step = Step.new(1, 'Given', 'a <color>cucumber')

        invocation_table = Table.new([
          ['color'],
          [nil]
        ])
        cells = invocation_table.cells_rows[1]
        step_invocation = step.step_invocation_from_cells(cells)
        
        step_invocation.name.should == 'a cucumber'
      end

      it "should replace arguments in table arg" do
        arg_table = Table.new([%w{taste_<taste> color_<color>}])

        step = Step.new(1, 'Given', 'a <color> cucumber', arg_table)

        invocation_table = Table.new([
          %w{color taste},
          %w{green juicy}
        ])
        cells = invocation_table.cells_rows[1]
        step_invocation = step.step_invocation_from_cells(cells)
        
        step_invocation.instance_variable_get('@multiline_arg').raw.should == [%w{taste_juicy color_green}]
      end

      it "should replace arguments in py string arg" do
        doc_string = DocString.new('taste_<taste> color_<color>')

        step = Step.new(1, 'Given', 'a <color> cucumber', doc_string)

        invocation_table = Table.new([
          %w{color taste},
          %w{green juicy}
        ])
        cells = invocation_table.cells_rows[1]
        step_invocation = step.step_invocation_from_cells(cells)
        
        step_invocation.instance_variable_get('@multiline_arg').to_step_definition_arg.should == 'taste_juicy color_green'
      end
    end
  end
end
