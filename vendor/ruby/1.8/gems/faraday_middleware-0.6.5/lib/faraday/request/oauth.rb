require 'faraday'

module Faraday
  class Request::OAuth < Faraday::Middleware
    dependency 'simple_oauth'

    def call(env)
      params = env[:body] || {}

      signature_params = params.reject{ |k,v| v.respond_to?(:content_type) }

      header = SimpleOAuth::Header.new(env[:method], env[:url], signature_params, @options)

      env[:request_headers]['Authorization'] = header.to_s

      @app.call(env)
    end

    def initialize(app, options)
      @app, @options = app, options
    end
  end
end
