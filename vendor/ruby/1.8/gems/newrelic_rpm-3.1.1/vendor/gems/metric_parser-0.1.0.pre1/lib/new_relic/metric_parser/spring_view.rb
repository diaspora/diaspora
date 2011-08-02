require 'new_relic/metric_parser/spring'
class NewRelic::MetricParser::SpringView < NewRelic::MetricParser::Spring
  def component_type
    "View"
  end
end
