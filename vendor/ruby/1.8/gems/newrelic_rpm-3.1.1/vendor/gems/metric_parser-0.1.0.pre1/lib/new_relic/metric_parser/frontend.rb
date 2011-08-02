class NewRelic::MetricParser::Frontend < NewRelic::MetricParser::MetricParser

=begin
  def action_name
    if segments[-1] =~ /^\(other\)$/
      '(template only)'
    else
      segments[-1]
    end
  end
=end

  def developer_name
    url
    #"#{controller_name}##{action_name}"
  end

  def short_name
    # standard controller actions
    if segments.length > 1
      url
    else
      'All Frontend Urls'
    end
  end

  def url
    '/' + segments[1..-1].join('/')
  end

  # this is used to match transaction traces to controller actions.
  # TT's don't have a preceding slash :P
  def tt_path
    segments[1..-1].join('/')
  end

  def call_rate_suffix
    'rpm'
  end
end
