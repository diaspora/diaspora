module Cucumber
  module Formatter
    module Duration
      # Helper method for formatters that need to
      # format a duration in seconds to the UNIX
      # <tt>time</tt> format.
      def format_duration(seconds)
        m, s = seconds.divmod(60)
        "#{m}m#{'%.3f' % s}s" 
      end
    end
  end
end
