require 'faraday'

module Faraday
  class Request::OAuth2 < Faraday::Middleware
    dependency 'oauth2'

    def call(env)
      params = env[:url].query_values || {}

      env[:url].query_values = { 'access_token' => @token }.merge(params)

      token = env[:url].query_values['access_token']

      env[:request_headers].merge!('Authorization' => "Token token=\"#{token}\"")

      @app.call env
    end

    def initialize(app, *args)
      @app = app
      @token = args.shift
    end
  end
end
