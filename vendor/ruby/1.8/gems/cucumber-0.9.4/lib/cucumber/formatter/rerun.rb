require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format rerun</tt>
    #
    # This formatter keeps track of all failing features and print out their location.
    # Example:
    #
    #   features/foo.feature:34 features/bar.feature:11:76:81
    #
    # This formatter is used by AutoTest - it will use the output to decide what
    # to run the next time, simply passing the output string on the command line.
    #
    class Rerun
      include Io

      def initialize(step_mother, path_or_io, options)
        @io = ensure_io(path_or_io, "rerun")
        @options = options
        @file_names = []
        @file_colon_lines = Hash.new{|h,k| h[k] = []}
      end

      # features() is never executed at all... ?
      def after_features(features)
        files = @file_names.uniq.map do |file|
          lines = @file_colon_lines[file]
          "#{file}:#{lines.join(':')}"
        end
        @io.puts files.join(' ')
        
        # Flusing output to rerun tempfile here...
        @io.flush
        @io.close
      end

      def before_feature_element(feature_element)
        @rerun = false
      end

      def after_feature_element(feature_element)
        if @rerun
          file, line = *feature_element.file_colon_line.split(':')
          @file_colon_lines[file] << line
          @file_names << file
        end
      end

      def step_name(keyword, step_match, status, source_indent, background)
        @rerun = true if [:failed, :pending, :undefined].index(status)
      end
    end
  end
end
