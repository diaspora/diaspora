module Faraday
  class Adapter < Middleware
    CONTENT_LENGTH = 'Content-Length'.freeze

    extend AutoloadHelper

    autoload_all 'faraday/adapter',
      :ActionDispatch => 'action_dispatch',
      :NetHttp        => 'net_http',
      :Typhoeus       => 'typhoeus',
      :EMSynchrony    => 'em_synchrony',
      :Patron         => 'patron',
      :Excon          => 'excon',
      :Test           => 'test'

    register_lookup_modules \
      :action_dispatch => :ActionDispatch,
      :test            => :Test,
      :net_http        => :NetHttp,
      :typhoeus        => :Typhoeus,
      :patron          => :Patron,
      :em_synchrony    => :EMSynchrony,
      :excon           => :Excon

    def call(env)
      if !env[:body] and Connection::METHODS_WITH_BODIES.include? env[:method]
        # play nice and indicate we're sending an empty body
        env[:request_headers][CONTENT_LENGTH] = "0"
        # Typhoeus hangs on PUT requests if body is nil
        env[:body] = ''
      end
    end

    def save_response(env, status, body, headers = nil)
      env[:status] = status
      env[:body] = body
      env[:response_headers] = Utils::Headers.new.tap do |response_headers|
        response_headers.update headers unless headers.nil?
        yield response_headers if block_given?
      end
    end
  end
end
