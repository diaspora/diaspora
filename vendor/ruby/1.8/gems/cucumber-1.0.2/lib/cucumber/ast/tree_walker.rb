module Cucumber
  module Ast
    # Walks the AST, executing steps and notifying listeners
    class TreeWalker
      attr_accessor :configuration #:nodoc:
      attr_reader   :step_mother #:nodoc:

      def initialize(step_mother, listeners = [], configuration = Cucumber::Configuration.default)
        @step_mother, @listeners, @configuration = step_mother, listeners, configuration
      end

      def visit_features(features)
        broadcast(features) do
          features.accept(self)
        end
      end

      def visit_feature(feature)
        broadcast(feature) do
          feature.accept(self)
        end
      end

      def visit_comment(comment)
        broadcast(comment) do
          comment.accept(self)
        end
      end

      def visit_comment_line(comment_line)
        broadcast(comment_line)
      end

      def visit_tags(tags)
        broadcast(tags) do
          tags.accept(self)
        end
      end

      def visit_tag_name(tag_name)
        broadcast(tag_name)
      end

      def visit_feature_name(keyword, name)
        broadcast(keyword, name)
      end

      # +feature_element+ is either Scenario or ScenarioOutline
      def visit_feature_element(feature_element)
        broadcast(feature_element) do
          feature_element.accept(self)
        end
      end

      def visit_background(background)
        broadcast(background) do
          background.accept(self)
        end
      end

      def visit_background_name(keyword, name, file_colon_line, source_indent)
        broadcast(keyword, name, file_colon_line, source_indent)
      end

      def visit_examples_array(examples_array)
        broadcast(examples_array) do
          examples_array.accept(self)
        end
      end

      def visit_examples(examples)
        broadcast(examples) do
          examples.accept(self)
        end
      end

      def visit_examples_name(keyword, name)
        broadcast(keyword, name)
      end

      def visit_outline_table(outline_table)
        broadcast(outline_table) do
          outline_table.accept(self)
        end
      end

      def visit_scenario_name(keyword, name, file_colon_line, source_indent)
        broadcast(keyword, name, file_colon_line, source_indent)
      end

      def visit_steps(steps)
        broadcast(steps) do
          steps.accept(self)
        end
      end

      def visit_step(step)
        broadcast(step) do
          step.accept(self)
        end
      end

      def visit_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        broadcast(keyword, step_match, multiline_arg, status, exception, source_indent, background) do
          visit_step_name(keyword, step_match, status, source_indent, background)
          visit_multiline_arg(multiline_arg) if multiline_arg
          visit_exception(exception, status) if exception
        end
      end

      def visit_step_name(keyword, step_match, status, source_indent, background) #:nodoc:
        broadcast(keyword, step_match, status, source_indent, background)
      end

      def visit_multiline_arg(multiline_arg) #:nodoc:
        broadcast(multiline_arg) do
          multiline_arg.accept(self)
        end
      end

      def visit_exception(exception, status) #:nodoc:
        broadcast(exception, status)
      end

      def visit_doc_string(string)
        broadcast(string)
      end

      def visit_table_row(table_row)
        broadcast(table_row) do
          table_row.accept(self)
        end
      end

      def visit_table_cell(table_cell)
        broadcast(table_cell) do
          table_cell.accept(self)
        end
      end

      def visit_table_cell_value(value, status)
        broadcast(value, status)
      end

      # Print +messages+. This method can be called from within StepDefinitions.
      def puts(*messages)
        broadcast(*messages)
      end

      # Embed +file+ of +mime_type+ in the formatter. This method can be called from within StepDefinitions.
      # For most formatters this is a no-op.
      def embed(file, mime_type, label)
        broadcast(file, mime_type, label)
      end
      
      private
      
      def broadcast(*args, &block)
        message = extract_method_name_from(caller)
        message.gsub!('visit_', '')
        if block_given?
          send_to_all("before_#{message}", *args)
          yield if block_given?
          send_to_all("after_#{message}", *args)
        else
          send_to_all(message, *args)
        end
      end
      
      def send_to_all(message, *args)
        @listeners.each do |listener|
          if listener.respond_to?(message)
            listener.__send__(message, *args)
          end
        end
      end
      def extract_method_name_from(call_stack)
        call_stack[0].match(/in `(.*)'/).captures[0]
      end
      
    end
  end
end