class NewRelic::MetricParser::DatabasePool < NewRelic::MetricParser::MetricParser

  def developer_name
    segs = segments
    if segs.length > 3
      segs[2,segs.length - 3].join("/")
    else
      name
    end
  end

  def pie_chart_label
    short_name
  end

  def tooltip_name
    developer_name + " " + last_segment
  end

  # class name with/out package name and method name
  def short_name
    developer_name
  end
end
