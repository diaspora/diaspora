require 'rspec/core/formatters/helpers'

module RSpec
  module Core
    module Formatters

      class BaseFormatter
        include Helpers
        attr_accessor :example_group
        attr_reader :duration, :examples, :output
        attr_reader :example_count, :pending_count, :failure_count
        attr_reader :failed_examples, :pending_examples

        def initialize(output)
          @output = output || StringIO.new
          @example_count = @pending_count = @failure_count = 0
          @examples = []
          @failed_examples = []
          @pending_examples = []
          @example_group = nil
        end

        # This method is invoked before any examples are run, right after
        # they have all been collected. This can be useful for special
        # formatters that need to provide progress on feedback (graphical ones)
        #
        # This will only be invoked once, and the next one to be invoked
        # is #example_group_started
        def start(example_count)
          start_sync_output
          @example_count = example_count
        end

        # This method is invoked at the beginning of the execution of each example group.
        # +example_group+ is the example_group.
        #
        # The next method to be invoked after this is +example_passed+,
        # +example_pending+, or +example_finished+
        def example_group_started(example_group)
          @example_group = example_group
        end

        # This method is invoked at the end of the execution of each example group.
        # +example_group+ is the example_group.
        def example_group_finished(example_group)
        end

        def example_started(example)
          examples << example
        end

        def example_passed(example)
        end

        def example_pending(example)
          @pending_examples << example
        end

        def example_failed(example)
          @failed_examples << example
        end

        def message(message)
        end

        def stop
        end

        # This method is invoked after all of the examples have executed. The next method
        # to be invoked after this one is #dump_failure (once for each failed example),
        def start_dump
        end

        # Dumps detailed information about each example failure.
        def dump_failures
        end

        # This method is invoked after the dumping of examples and failures.
        def dump_summary(duration, example_count, failure_count, pending_count)
          @duration = duration
          @example_count = example_count
          @failure_count = failure_count
          @pending_count = pending_count
        end

        # This gets invoked after the summary if option is set to do so.
        def dump_pending
        end

        # This method is invoked at the very end. Allows the formatter to clean up, like closing open streams.
        def close
          restore_sync_output
        end

        def format_backtrace(backtrace, example)
          return "" unless backtrace
          return backtrace if example.metadata[:full_backtrace] == true
          cleansed = backtrace.map { |line| backtrace_line(line) }.compact
          cleansed.empty? ? backtrace : cleansed
        end

      protected

        def configuration
          RSpec.configuration
        end

        def backtrace_line(line)
          return nil if configuration.cleaned_from_backtrace?(line)
          line = line.sub(File.expand_path("."), ".")
          line = line.sub(/\A([^:]+:\d+)$/, '\\1')
          return nil if line == '-e:1'
          line
        end

        def read_failed_line(exception, example)
          unless matching_line = find_failed_line(exception.backtrace, example.file_path)
            return "Unable to find matching line from backtrace"
          end

          file_path, line_number = matching_line.match(/(.+?):(\d+)(|:\d+)/)[1..2]

          if File.exist?(file_path)
            open(file_path, 'r') { |f| f.readlines[line_number.to_i - 1] }
          else
            "Unable to find #{file_path} to read failed line"
          end
        end

        def find_failed_line(backtrace, path)
          backtrace.detect { |line|
            match = line.match(/(.+?):(\d+)(|:\d+)/)
            match && match[1].downcase == path.downcase
          }

        end

        def start_sync_output
          @old_sync, output.sync = output.sync, true if output_supports_sync
        end

        def restore_sync_output
          output.sync = @old_sync if output_supports_sync and !output.closed?
        end

        def output_supports_sync
          output.respond_to?(:sync=)
        end

        def profile_examples?
          configuration.profile_examples
        end

        def color_enabled?
          configuration.color_enabled?
        end

      end

    end
  end
end
