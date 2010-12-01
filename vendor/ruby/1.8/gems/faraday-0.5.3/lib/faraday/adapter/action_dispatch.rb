module Faraday
  class Adapter
    class ActionDispatch < Faraday::Adapter
      attr_reader :session

      # Initializes a new middleware instance for each request.  Instead of
      # initiating an HTTP request with a web server, this adapter calls
      # a Rails 3 app using integration tests.
      #
      # app     - The current Faraday request.
      # session - An ActionDispatch::Integration::Session instance.
      #
      # Returns nothing.
      def initialize(app, session)
        super(app)
        @session = session
        @session.reset!
      end

      def call(env)
        super
        full_path = full_path_for(env[:url].path, env[:url].query, env[:url].fragment)
        @session.__send__(env[:method], full_path, env[:body], env[:request_headers])
        resp = @session.response
        env.update \
          :status           => resp.status,
          :response_headers => resp.headers,
          :body             => resp.body
        @app.call env
      end

      # TODO: build in support for multipart streaming if action dispatch supports it.
      def create_multipart(env, params, boundary = nil)
        stream = super
        stream.read
      end
    end
  end
end
