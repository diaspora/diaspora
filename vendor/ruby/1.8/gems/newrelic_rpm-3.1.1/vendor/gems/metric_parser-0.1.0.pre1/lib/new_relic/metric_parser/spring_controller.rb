require 'new_relic/metric_parser/spring'
class NewRelic::MetricParser::SpringController < NewRelic::MetricParser::Spring
  def component_type
    "Controller"
  end
end
