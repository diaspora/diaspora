require 'cucumber/core_ext/string'
require 'cucumber/step_match'

module Cucumber
  module Ast
    class Step #:nodoc:
      attr_reader :line, :keyword, :name
      attr_writer :step_collection, :options
      attr_accessor :feature_element, :exception, :multiline_arg

      INDENT = 2
      
      def initialize(line, keyword, name, multiline_arg=nil)
        @line, @keyword, @name, @multiline_arg = line, keyword, name, multiline_arg
      end

      attr_reader :gherkin_statement
      def gherkin_statement(statement=nil)
        @gherkin_statement ||= statement
      end

      def background?
        false
      end

      def status
        # Step always has status skipped, because Step is always in a ScenarioOutline
        :skipped
      end

      def step_invocation
        StepInvocation.new(self, @name, @multiline_arg, [])
      end

      def step_invocation_from_cells(cells)
        matched_cells = matched_cells(cells)

        delimited_arguments = delimit_argument_names(cells.to_hash)
        name                = replace_name_arguments(delimited_arguments)
        multiline_arg       = @multiline_arg.nil? ? nil : @multiline_arg.arguments_replaced(delimited_arguments)

        StepInvocation.new(self, name, multiline_arg, matched_cells)
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        # The only time a Step is visited is when it is in a ScenarioOutline.
        # Otherwise it's always StepInvocation that gets visited instead.
        visit_step_result(visitor, first_match(visitor), @multiline_arg, :skipped, nil, nil)
      end
      
      def visit_step_result(visitor, step_match, multiline_arg, status, exception, background)
        visitor.visit_step_result(@keyword, step_match, @multiline_arg, status, exception, source_indent, background)
      end

      def first_match(visitor)
        # @feature_element is always a ScenarioOutline in this case
        @feature_element.each_example_row do |cells|
          argument_hash       = cells.to_hash
          delimited_arguments = delimit_argument_names(argument_hash)
          name                = replace_name_arguments(delimited_arguments)
          step_match          = visitor.step_mother.step_match(name, @name) rescue nil
          return step_match if step_match
        end
        NoStepMatch.new(self, @name)
      end

      def to_sexp
        [:step, @line, @keyword, @name, (@multiline_arg.nil? ? nil : @multiline_arg.to_sexp)].compact
      end

      def source_indent
        @feature_element.source_indent(text_length)
      end

      def text_length(name=@name)
        INDENT + INDENT + @keyword.unpack('U*').length + name.unpack('U*').length
      end

      def backtrace_line
        @backtrace_line ||= @feature_element.backtrace_line("#{@keyword}#{@name}", @line) unless @feature_element.nil?
      end

      def file_colon_line
        @file_colon_line ||= @feature_element.file_colon_line(@line) unless @feature_element.nil?
      end

      def language
        @feature_element.language
      end

      def dom_id
        @dom_id ||= file_colon_line.gsub(/\//, '_').gsub(/\./, '_').gsub(/:/, '_')
      end

      private

      def matched_cells(cells)
        col_index = 0
        cells.select do |cell|
          header_cell = cell.table.header_cell(col_index)
          col_index += 1
          delimited = delimited(header_cell.value)
          @name.index(delimited) || (@multiline_arg && @multiline_arg.has_text?(delimited))
        end
      end

      def delimit_argument_names(argument_hash)
        argument_hash.inject({}) { |h,(name,value)| h[delimited(name)] = value; h }
      end

      def delimited(s)
        "<#{s}>"
      end

      def replace_name_arguments(argument_hash)
        name_with_arguments_replaced = @name
        argument_hash.each do |name, value|
          value ||= ''
          name_with_arguments_replaced = name_with_arguments_replaced.gsub(name, value)
        end
        name_with_arguments_replaced
      end
    end
  end
end
