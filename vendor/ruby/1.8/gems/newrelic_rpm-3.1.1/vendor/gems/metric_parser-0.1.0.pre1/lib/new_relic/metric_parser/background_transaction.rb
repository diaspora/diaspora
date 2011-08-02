require 'new_relic/metric_parser/java'
class NewRelic::MetricParser::BackgroundTransaction < NewRelic::MetricParser::Java

  def call_rate_suffix
    'cpm'
  end
end
