require 'enumerator'
require 'gherkin/tag_expression'

module Cucumber
  module Ast
    module FeatureElement #:nodoc:
      attr_accessor :feature

      attr_reader :gherkin_statement, :raw_steps, :title, :description
      def gherkin_statement(statement=nil)
        @gherkin_statement ||= statement
      end

      def add_step(step)
        @raw_steps << step
      end

      def attach_steps(steps)
        steps.each {|step| step.feature_element = self}
      end

      def file_colon_line(line = @line)
        @feature.file_colon_line(line) if @feature
      end

      def first_line_length
        name_line_lengths[0]
      end

      def text_length
        name_line_lengths.max
      end

      def name_line_lengths
        if name.strip.empty?
          [Ast::Step::INDENT + @keyword.unpack('U*').length + ': '.length]
        else
          name.split("\n").enum_for(:each_with_index).map do |line, line_number|
            if line_number == 0
              Ast::Step::INDENT + @keyword.unpack('U*').length + ': '.length + line.unpack('U*').length
            else
              Ast::Step::INDENT + Ast::Step::INDENT + line.unpack('U*').length
            end
          end
        end
      end

      def matches_scenario_names?(scenario_name_regexps)
        scenario_name_regexps.detect{|n| n =~ name}
      end

      def backtrace_line(name = "#{@keyword}: #{name}", line = @line)
        @feature.backtrace_line(name, line) if @feature
      end

      def source_indent(text_length)
        max_line_length - text_length
      end

      def max_line_length
        init
        @steps.max_line_length(self)
      end

      def accept_hook?(hook)
        Gherkin::TagExpression.new(hook.tag_expressions).eval(source_tag_names)
      end

      def source_tag_names
        (@tags.tag_names.to_a + (@feature ? @feature.source_tag_names.to_a : [])).uniq
      end

      def language
        @feature.language if @feature
      end
    end
  end
end
