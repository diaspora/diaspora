require 'new_relic/metric_parser'
module NewRelic
  module MetricParser
    class Errors < NewRelic::MetricParser::MetricParser
      def is_error?; true; end
      def short_name
        segments[2..-1].join(NewRelic::MetricParser::MetricParser::SEPARATOR)
      end
    end
  end
end
