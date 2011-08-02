module Gherkin
  module Listener
    class Event < Array
      def event
        self[0]
      end

      def keyword
        self[1]
      end
      
      def line_match?(lines)
        lines.include?(line)
      end

      def name_match?(name_regexen)
        return false unless [:feature, :background, :scenario, :scenario_outline, :examples].include?(event)
        name_regexen.detect{|name_regex| name =~ name_regex}
      end

      def replay(listener)
        begin
          listener.__send__(event, *args)
        rescue ArgumentError => e
          e.message << "\nListener: #{listener.class}, args: #{args.inspect}"
          raise e
        end
      end

    private

      def name
        self[2]
      end

      def line
        self[-1]
      end

      def args
        self[1..-1]
      end
    end
  end
end
