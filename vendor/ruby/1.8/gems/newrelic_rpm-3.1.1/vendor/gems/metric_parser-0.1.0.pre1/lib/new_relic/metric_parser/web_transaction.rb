class NewRelic::MetricParser::WebTransaction < NewRelic::MetricParser::MetricParser

  def is_web_transaction?; true; end
  def is_transaction?; true; end

  module Controller
    def category; 'Controller'; end
    # If the controller name segments look like a file path, convert it to the controller
    # class name.  If it begins with a capital letter, assume it's already a class name
    def controller_name
      path = segments[2..-2].join('/')
      path < 'a' ? path : camelize(path)+"Controller"
    end

    def action_name
      segments[-1]
    end

    def developer_name
      if action_name
        "#{controller_name}##{action_name}"
      else
        controller_name
      end
    end
    def short_name
      developer_name

    end

    private
    # Wow, ugliness. Ganked from Rails to make metric parser rails-free
    def camelize(str)
      str.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end

  # Like a controller but 2nd segment is always full class name,
  # and 3rd segment (optional) is the action name
  module Task
    include Controller
    def is_web_transaction?; false; end
    def category; 'Task'; end
    def action_name; segments[3]; end
    def controller_name; segments[2]; end
  end

  module Rack
    include Task

    def is_web_transaction?; true; end
    def category; 'Rack App'; end
  end

  module Spring
    def category; 'Spring Transaction'; end
  end

  module SpringView
    def is_web_transaction?; true; end
    def category; 'Spring View'; end
  end

  module SpringController
    def is_web_transaction?; true; end
    def category; 'Spring Controller'; end
  end

  module Solr
    def category; 'Solr Request'; end
  end

  module CXF
    def category; 'CXF Transaction'; end
  end

  module Pattern
    def category;'Pattern';end
    def developer_name
      "#{category}: #{pattern}"
    end
    def pattern
      segments[2..-1].join('/')
    end
    def short_name
      pattern
    end
  end

  module Sinatra
    include Pattern
    def is_web_transaction?; true; end
    def category; 'Sinatra'; end
  end

  def initialize(name)
    super
    if %w[Sinatra Spring SpringController SpringView Solr CXF Task Pattern Rack Controller].include?(segment_1)
      self.extend NewRelic::MetricParser::WebTransaction.const_get(segment_1)
    end
  end

  def developer_name
    url
  end

  def short_name
    if segments.length > 2
      developer_name
    else
      'All Web Transactions'
    end
  end

  def url
    '/' + segments[2..-1].join('/')
  end

  # this is used to match transaction traces to controller actions.
  # TT's don't have a preceding slash :P
  def tt_path
    segments[2..-1].join('/')
  end

  def call_rate_suffix
    'rpm'
  end

  # default to v2 Web Transactions tab
  def drilldown_url(metric_id)
    {:controller => '/v2/transactions', :action => 'index', :anchor => "id=#{metric_id}"}
  end
end
