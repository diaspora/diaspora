class NewRelic::MetricParser::Client < NewRelic::MetricParser::MetricParser

  def measure
    segments[1]
  end

  def frontend?; measure == 'frontend'; end
  def backend?; measure == 'backend'; end
  def totaltime?; measure == 'totaltime'; end

  def all?
    segments[1].index('all') == 0
  end

  def operation
    all? ? 'All Operations' : segments[1].titleize.gsub(/(load|ready|time|end)$/,' \1')
  end

  def legend_name
    if frontend?
      "Browser Rendering and Asset Download"
    elsif backend?
      "Backend and Network"
    else
      segments[1..-1].join(" ")
    end
  end

  def platform
    segments[2]
  end

  def user_agent
    segments[3..-1].join(" ")
  end

  def platform_and_user_agent
    segments[2..-1].join(" ")
  end

  def developer_name
    name = segments[1].capitalize
    name << " (#{segments[2..-1].join(" ")})" if segments.length > 2
    name
  end
end
