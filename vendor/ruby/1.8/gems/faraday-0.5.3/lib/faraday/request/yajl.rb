module Faraday
  class Request::Yajl < Faraday::Middleware
    begin
      require 'yajl'

    rescue LoadError, NameError => e
      self.load_error = e
    end

    def call(env)
      env[:request_headers]['Content-Type'] = 'application/json'
      if env[:body] && !env[:body].respond_to?(:to_str)
        env[:body] = Yajl::Encoder.encode(env[:body])
      end
      @app.call env
    end
  end
end
