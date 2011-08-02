require 'new_relic/metric_parser/java'
class NewRelic::MetricParser::ServletFilter < NewRelic::MetricParser::Java

  def call_rate_suffix
    'cpm'
  end
end
