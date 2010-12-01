module Treetop
  module Runtime
    class TerminalParseFailure
      attr_reader :index

      def initialize(index, expected_string)
        @index = index
        @caller = caller
        @expected_string = expected_string
      end

      def expected_string
        "#{@expected_string} from #{@caller.map{|s| s.sub(/\A.*:([0-9]+):in `([^']*)'.*/,'\2:\1')}*" from "}\n\t"
      end

      def to_s
        "String matching #{expected_string} expected."
      end
    end
  end
end
