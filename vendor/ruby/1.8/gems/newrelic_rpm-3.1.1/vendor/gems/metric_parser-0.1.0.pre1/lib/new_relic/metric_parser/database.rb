class NewRelic::MetricParser::Database < NewRelic::MetricParser::MetricParser
  def is_database?; true; end

  def database
    segments[1]
  end

  def operation
    op = segments.last
    case
      when op == 'Join Table Columns'
        op.upcase
      when op == 'all'
        op
    else
      op.split(' ').last.upcase
    end
  end

  def developer_name
    if segments.size == 3
      "#{database} - #{operation}"
    else
      operation
    end
  end

  def legend_name
    if all?
      'Database'
    else
      super
    end
  end

  def tooltip_name
    if all?
      'all SQL execution'
    else
      super
    end
  end

  private
  def all?
    name == 'Database/all' || name == 'Database/allWeb' || name == 'Database/allOther'
  end
end
