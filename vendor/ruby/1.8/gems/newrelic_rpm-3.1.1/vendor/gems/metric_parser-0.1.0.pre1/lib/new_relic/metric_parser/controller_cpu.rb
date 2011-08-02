require 'new_relic/metric_parser'
module NewRelic
  module MetricParser
    class ControllerCPU < NewRelic::MetricParser::MetricParser

      def is_controller_cpu?; true; end

      def controller_name
        segments[1..-2].join('/').camelize+"Controller"
      end

      def action_name
        segments[-1]
      end

      def developer_name
        "#{controller_name}##{action_name}"
      end

      def base_metric_name
        "Controller/" + segments[1..-1].join('/')
      end

      def short_name
        # standard controller actions
        if segments.length > 1
          url
        else
          'All Controller Actions'
        end
      end

      def url
        '/' + segments[1..-1].join('/')
      end

      def call_rate_suffix
        'rpm'
      end

    end
  end
end
