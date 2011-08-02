require 'new_relic/metric_parser'
module NewRelic
  module MetricParser
    class WebService < NewRelic::MetricParser::MetricParser
      def is_web_service?
        segments[1] != 'Soap' && segments[1] != 'Xml Rpc'
      end

      def webservice_call_rate_suffix
        'rpm'
      end
    end
  end
end
