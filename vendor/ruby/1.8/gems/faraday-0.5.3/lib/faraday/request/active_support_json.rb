module Faraday
  class Request::ActiveSupportJson < Faraday::Middleware
    begin
      if !defined?(ActiveSupport::JSON)
        require 'active_support'
        ActiveSupport::JSON
      end

    rescue LoadError, NameError => e
      self.load_error = e
    end

    def call(env)
      env[:request_headers]['Content-Type'] = 'application/json'
      if env[:body] && !env[:body].respond_to?(:to_str)
        env[:body] = ActiveSupport::JSON.encode(env[:body])
      end
      @app.call env
    end
  end
end
