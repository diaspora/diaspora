require 'new_relic/metric_parser'
# The metric where the mongrel queue time is stored
module NewRelic
  module MetricParser
    class WebFrontend < NewRelic::MetricParser::MetricParser
      def short_name
        if segments.last == 'Average Queue Time'
          'Mongrel Average Queue Time'
        else
          super
        end
      end
      def legend_name
        'Mongrel Wait'
      end
    end
  end
end
