require 'rack/openid'
require 'rack/request'

module Rack #:nodoc:
  class OpenID
    # A simple OpenID middleware that restricts access to
    # a single identifier.
    #
    #   use Rack::OpenID::SimpleAuth, "http://example.org"
    #
    # SimpleAuth will automatically insert the required Rack::OpenID
    # middleware, so <tt>use Rack::OpenID</tt> is unnecessary.
    class SimpleAuth
      def self.new(*args)
        Rack::OpenID.new(super)
      end

      attr_reader :app, :identifier

      def initialize(app, identifier)
        @app        = app
        @identifier = identifier
      end

      def call(env)
        if session_authenticated?(env)
          app.call(env)
        elsif successful_response?(env)
          authenticate_session(env)
          redirect_to requested_url(env)
        else
          authentication_request
        end
      end

      private
        def session(env)
          env['rack.session'] || raise_session_error
        end

        def raise_session_error
          raise RuntimeError, 'Rack::OpenID::SimpleAuth requires a session'
        end

        def session_authenticated?(env)
          session(env)['authenticated'] == true
        end

        def authenticate_session(env)
          session(env)['authenticated'] = true
        end

        def successful_response?(env)
          if resp = env[OpenID::RESPONSE]
            resp.status == :success && resp.display_identifier == identifier
          end
        end

        def requested_url(env)
          req = Rack::Request.new(env)
          req.url
        end

        def redirect_to(url)
          [303, {'Content-Type' => 'text/html', 'Location' => url}, []]
        end

        def authentication_request
          [401, { OpenID::AUTHENTICATE_HEADER => www_authenticate_header }, []]
        end

        def www_authenticate_header
          OpenID.build_header(:identifier => identifier)
        end
    end
  end
end
