module Gherkin
  module Formatter
    class RegexpFilter
      def initialize(regexen)
        @regexen = regexen
      end

      def eval(tags, names, ranges)
        @regexen.detect do |regexp| 
          names.detect do |name|
            name =~ regexp
          end
        end
      end

      def filter_table_body_rows(rows)
        rows
      end
    end
  end
end