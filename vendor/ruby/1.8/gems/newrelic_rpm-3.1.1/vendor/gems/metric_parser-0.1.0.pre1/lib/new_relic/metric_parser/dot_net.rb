require 'new_relic/metric_parser/dot_net_parser'

class NewRelic::MetricParser::DotNet < NewRelic::MetricParser::MetricParser

  def initialize(name)
    super
    if segments.length > 2
      self.extend DotNetParser
    end
  end

  def pie_chart_label
    short_name
  end

  def tooltip_name
    developer_name
  end

  def full_class_name
    segment_1
  end

  def method_name
    segment_2
  end

end
