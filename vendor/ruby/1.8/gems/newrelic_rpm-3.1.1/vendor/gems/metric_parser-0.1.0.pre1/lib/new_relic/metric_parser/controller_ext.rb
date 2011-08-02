# Extend the controller with extra behavior from web transactions
# This is just temporary until we switchover to WebTransaction from Controller.

NewRelic::MetricParser::Controller.class_eval do

  def initialize(name)
    super
    if %w[Sinatra Rack Task].include?(segment_1)
      self.extend NewRelic::MetricParser::WebTransaction.const_get(segment_1)
    end
  end

  # default to v2 Web Transactions tab
  def drilldown_url(metric_id)
    {:controller => '/v2/transactions', :action => 'index', :anchor => "id=#{metric_id}"}
  end
end
