module NewRelic
  class Control
    module Profiling

      # A flag used in dev mode to indicate if profiling is available
      def profiling?
        @profiling
      end

      def profiling_available?
        @profiling_available ||=
          begin
            require 'ruby-prof'
            true
          rescue LoadError; end
      end
      # Set the flag for capturing profiles in dev mode.  If RubyProf is not
      # loaded a true value is ignored.
      def profiling=(val)
        @profiling = profiling_available? && val && defined?(RubyProf)
      end
    end
    include Profiling
  end
end
