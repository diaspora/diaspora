require 'new_relic/metric_parser/java'
class NewRelic::MetricParser::HibernateSession < NewRelic::MetricParser::Java

  def call_rate_suffix
    'cpm'
  end
end
