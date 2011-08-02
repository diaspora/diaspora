require 'new_relic/metric_parser'
module NewRelic
  module MetricParser
    class ActiveRecord < NewRelic::MetricParser::MetricParser
      def is_active_record? ; true; end

      def model_class
        return segments[1]
      end

      def is_database?
        true
      end
      def legend_name
        if name == 'ActiveRecord/all'
          'Database'
        else
          super
        end
      end
      def tooltip_name
        if name == 'ActiveRecord/all'
          'all SQL execution'
        else
          super
        end
      end
      def developer_name
        "#{model_class}##{segments.last}"
      end
    end
  end
end
