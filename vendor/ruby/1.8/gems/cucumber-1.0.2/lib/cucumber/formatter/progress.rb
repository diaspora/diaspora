require 'cucumber/formatter/console'
require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format progress</tt>
    class Progress
      include Console
      include Io
      attr_reader :step_mother

      def initialize(step_mother, path_or_io, options)
        @step_mother, @io, @options = step_mother, ensure_io(path_or_io, "progress"), options
      end

      def after_features(features)
        @io.puts
        @io.puts
        print_summary(features)
      end

      def before_feature_element(*args)
        @exception_raised = false
      end

      def after_feature_element(*args)
        progress(:failed) if @exception_raised
        @exception_raised = false
      end

      def before_steps(*args)
        progress(:failed) if @exception_raised
        @exception_raised = false
      end

      def after_steps(*args)
        @exception_raised = false
      end

      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        progress(status)
        @status = status
      end

      def before_outline_table(outline_table)
        @outline_table = outline_table
      end

      def after_outline_table(outline_table)
        @outline_table = nil
      end

      def table_cell_value(value, status)
        return unless @outline_table
        status ||= @status
        progress(status) unless table_header_cell?(status)
      end

      def exception(*args)
        @exception_raised = true
      end

      private

      def print_summary(features)
        print_steps(:pending)
        print_steps(:failed)
        print_stats(features, @options)
        print_snippets(@options)
        print_passing_wip(@options)
      end

      CHARS = {
        :passed    => '.',
        :failed    => 'F',
        :undefined => 'U',
        :pending   => 'P',
        :skipped   => '-'
      }

      def progress(status)
        char = CHARS[status]
        @io.print(format_string(char, status))
        @io.flush
      end

      def table_header_cell?(status)
        status == :skipped_param
      end
    end
  end
end
