require 'new_relic/metric_parser'
module NewRelic
  module MetricParser
    class External < NewRelic::MetricParser::MetricParser

      def all?
        host == 'all' || host == 'allWeb' || host == 'allOther'
      end
      def hosts_all?
        library == 'all'
      end
      def host
        segments[1]
      end
      def library
        segments[2]
      end
      def operation
        segments[3] && segments[3..-1].join("/")
      end
      def legend_name
        case
        when all?
          "External Services"
        when hosts_all?
          "All #{host} calls"
        else
          developer_name
        end
      end
      def tooltip_name
        case
        when all?
          "calls to external systems"
        when hosts_all?
          "calls to #{host}"
        else
          "calls to #{developer_name}"
        end
      end
      def developer_name
        case
        when all?
          'All External'
        when hosts_all?
          host
        when operation
          "#{library}[#{host}]: #{operation}"
        else
          "#{library}[#{host}]"
        end
      end
    end
  end
end
