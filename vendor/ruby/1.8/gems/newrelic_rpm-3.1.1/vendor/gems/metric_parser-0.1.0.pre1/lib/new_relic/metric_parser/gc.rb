class NewRelic::MetricParser::GC < NewRelic::MetricParser::MetricParser

  def developer_name
    if segments.length == 1
      "GC"
    elsif segment_1 == "cumulative"
      "GC Execution"
    else
      "GC - #{segment_1}"
    end
  end

  def short_name
    if segments.length > 1
      developer_name
    else
      'All GCs'
    end
  end
end
