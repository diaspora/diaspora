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
        @session.__send__(env[:method], env[:url].request_uri, env[:body], env[:request_headers])
        resp = @session.response
        save_response(env, resp.status, resp.body, resp.headers)
        @app.call env
      end
    end
  end
end
