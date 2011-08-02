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
      
      def before_feature(*)
        @lines = []
        @file = nil
      end
      
      def after_feature(*)
        unless @lines.empty?
          after_first_time do
            @io.print ' '
          end
          @io.print "#{@file}:#{@lines.join(':')}"
          @io.flush
        end
      end

      def after_features(features)
        @io.close
      end

      def before_feature_element(feature_element)
        @rerun = false
      end

      def after_feature_element(feature_element)
        if @rerun
          file, line = *feature_element.file_colon_line.split(':')
          @lines << line
          @file = file
        end
      end

      def step_name(keyword, step_match, status, source_indent, background)
        @rerun = true if [:failed, :pending, :undefined].index(status)
      end
      
    private
    
      def after_first_time
        yield if @not_first_time
        @not_first_time = true
      end
    end
  end
end
