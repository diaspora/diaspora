require 'rspec/core/formatters/base_text_formatter'

module RSpec
  module Core
    module Formatters

      class DocumentationFormatter < BaseTextFormatter

        def initialize(output)
          super(output)
          @group_level = 0
        end

        def example_group_started(example_group)
          super(example_group)

          output.puts if @group_level == 0
          output.puts "#{'  ' * @group_level}#{example_group.description}"

          @group_level += 1
        end

        def example_group_finished(example_group)
          @group_level -= 1
        end

        def example_passed(example)
          super(example)
          output.puts passed_output(example)
        end

        def example_pending(example)
          super(example)
          output.puts pending_output(example, example.execution_result[:pending_message])
        end

        def example_failed(example)
          super(example)
          output.puts failure_output(example, example.execution_result[:exception_encountered])
        end

        def failure_output(example, exception)
          red("#{current_indentation}#{example.description} (FAILED - #{next_failure_index})")
        end

        def next_failure_index
          @next_failure_index ||= 0
          @next_failure_index += 1
        end

        def passed_output(example)
          green("#{current_indentation}#{example.description}")
        end

        def pending_output(example, message)
          yellow("#{current_indentation}#{example.description} (PENDING: #{message})")
        end

        def current_indentation
          '  ' * @group_level
        end

        def example_group_chain
          example_group.ancestors.reverse
        end

      end

    end
  end
end
