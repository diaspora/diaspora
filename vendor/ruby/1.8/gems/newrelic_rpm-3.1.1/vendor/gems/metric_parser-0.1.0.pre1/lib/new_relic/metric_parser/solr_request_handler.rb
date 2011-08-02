#require 'new_relic/metric_parser/java'
class NewRelic::MetricParser::SolrRequestHandler < NewRelic::MetricParser::MetricParser

  def short_name
    if segments[1] == "org.apache.solr.handler.XmlUpdateRequestHandler"
      "UpdateProcessor"
    else
      super
    end
  end

  def call_rate_suffix
    'cpm'
  end
end
