class NewRelic::MetricParser::Spring < NewRelic::MetricParser::MetricParser
  def initialize(name)
    super

    if segment_1 == 'Java'
      self.extend JavaParser
    end
=begin
    case segment_1
      when 'Controller'
        self.extend NewRelic::MetricParser::Spring::Controller
      when 'View'
        self.extend NewRelic::MetricParser::Spring::View
    end
=end
  end


  def pie_chart_label
    short_name
  end

  def tooltip_name
    developer_name
  end

  def component_type
    'Spring'
  end

  def short_name
    component_type + ' ' + developer_name
  end

  def developer_name
    '/' + segments[1..-1].join(SEPARATOR)
  end

  module JavaParser
    def developer_name
      "#{segment_2}.#{segment_3}()"
    end

    def class_name_without_package
      segment_2 =~ /(.*\.)(.*)$/ ? $2 : segment_2
    end

    # class name with/out package name and method name
    def short_name
      "#{component_type} #{class_name_without_package}.#{segment_3}()"
    end

  end
end
