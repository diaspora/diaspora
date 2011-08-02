module FaradayStack
  # Measures request time only in synchronous request mode.
  # Sample subscriber:
  #
  #   ActiveSupport::Notifications.subscribe('request.faraday') do |name, start_time, end_time, _, env|
  #     url = env[:url]
  #     http_method = env[:method].to_s.upcase
  #     duration = end_time - start_time
  #     $stderr.puts '[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration]
  #   end
  class Instrumentation < Faraday::Middleware
    dependency 'active_support/notifications'
    
    def initialize(app, options = {})
      super(app)
      @options = options
      @name = options[:name] || 'request.faraday'
    end
    
    def call(env)
      ActiveSupport::Notifications.instrument(@name, env) do
        @app.call(env)
      end
    end
  end
end
