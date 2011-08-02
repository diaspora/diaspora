require 'rack/request'
require 'rack/utils'

require 'openid'
require 'openid/consumer'
require 'openid/extensions/sreg'
require 'openid/extensions/ax'
require 'openid/extensions/oauth'

module Rack #:nodoc:
  # A Rack middleware that provides a more HTTPish API around the
  # ruby-openid library.
  #
  # You trigger an OpenID request similar to HTTP authentication.
  # From your app, return a "401 Unauthorized" and a "WWW-Authenticate"
  # header with the identifier you would like to validate.
  #
  # On competition, the OpenID response is automatically verified and
  # assigned to <tt>env["rack.openid.response"]</tt>.
  class OpenID
    # Helper method for building the "WWW-Authenticate" header value.
    #
    #   Rack::OpenID.build_header(:identifier => "http://josh.openid.com/")
    #     #=> OpenID identifier="http://josh.openid.com/"
    def self.build_header(params = {})
      'OpenID ' + params.map { |key, value|
        if value.is_a?(Array)
          "#{key}=\"#{value.join(',')}\""
        else
          "#{key}=\"#{value}\""
        end
      }.join(', ')
    end

    # Helper method for parsing "WWW-Authenticate" header values into
    # a hash.
    #
    #   Rack::OpenID.parse_header("OpenID identifier='http://josh.openid.com/'")
    #     #=> {:identifier => "http://josh.openid.com/"}
    def self.parse_header(str)
      params = {}
      if str =~ AUTHENTICATE_REGEXP
        str = str.gsub(/#{AUTHENTICATE_REGEXP}\s+/, '')
        str.split(', ').each { |pair|
          key, *value = pair.split('=')
          value = value.join('=')
          value.gsub!(/^\"/, '').gsub!(/\"$/, "")
          value = value.split(',')
          params[key] = value.length > 1 ? value : value.first
        }
      end
      params
    end

    class TimeoutResponse #:nodoc:
      include ::OpenID::Consumer::Response
      STATUS = :failure
    end

    class MissingResponse #:nodoc:
      include ::OpenID::Consumer::Response
      STATUS = :missing
    end

    # :stopdoc:

    HTTP_METHODS = %w(GET HEAD PUT POST DELETE OPTIONS)

    RESPONSE = "rack.openid.response"
    AUTHENTICATE_HEADER = "WWW-Authenticate"
    AUTHENTICATE_REGEXP = /^OpenID/

    URL_FIELD_SELECTOR = lambda { |field| field.to_s =~ %r{^https?://} }

    # :startdoc:

    # Initialize middleware with application and optional OpenID::Store.
    # If no store is given, OpenID::Store::Memory is used.
    #
    #   use Rack::OpenID
    #
    # or
    #
    #   use Rack::OpenID, OpenID::Store::Memcache.new
    def initialize(app, store = nil)
      @app = app
      @store = store || default_store
    end

    # Standard Rack +call+ dispatch that accepts an +env+ and
    # returns a <tt>[status, header, body]</tt> response.
    def call(env)
      req = Rack::Request.new(env)
      if req.params["openid.mode"]
        complete_authentication(env)
      end

      status, headers, body = @app.call(env)

      qs = headers[AUTHENTICATE_HEADER]
      if status.to_i == 401 && qs && qs.match(AUTHENTICATE_REGEXP)
        begin_authentication(env, qs)
      else
        [status, headers, body]
      end
    end

    private
      def begin_authentication(env, qs)
        req = Rack::Request.new(env)
        params = self.class.parse_header(qs)
        session = env["rack.session"]

        unless session
          raise RuntimeError, "Rack::OpenID requires a session"
        end

        consumer   = ::OpenID::Consumer.new(session, @store)
        identifier = params['identifier'] || params['identity']
        immediate  = params['immediate'] == 'true'

        begin
          oidreq = consumer.begin(identifier)
          add_simple_registration_fields(oidreq, params)
          add_attribute_exchange_fields(oidreq, params)
          add_oauth_fields(oidreq, params)
          url = open_id_redirect_url(req, oidreq, params["trust_root"], params["return_to"], params["method"], immediate)
          return redirect_to(url)
        rescue ::OpenID::OpenIDError, Timeout::Error => e
          env[RESPONSE] = MissingResponse.new
          return @app.call(env)
        end
      end

      def complete_authentication(env)
        req = Rack::Request.new(env)
        session = env["rack.session"]

        unless session
          raise RuntimeError, "Rack::OpenID requires a session"
        end

        oidresp = timeout_protection_from_identity_server {
          consumer = ::OpenID::Consumer.new(session, @store)
          consumer.complete(flatten_params(req.params), req.url)
        }

        env[RESPONSE] = oidresp

        method = req.GET["_method"]
        override_request_method(env, method)

        sanitize_query_string(env)
      end

      def flatten_params(params)
        Rack::Utils.parse_query(Rack::Utils.build_nested_query(params))
      end

      def override_request_method(env, method)
        return unless method
        method = method.upcase
        if HTTP_METHODS.include?(method)
          env["REQUEST_METHOD"] = method
        end
      end

      def sanitize_query_string(env)
        query_hash = env["rack.request.query_hash"]
        query_hash.delete("_method")
        query_hash.delete_if do |key, value|
          key =~ /^openid\./
        end

        env["QUERY_STRING"] = env["rack.request.query_string"] =
          Rack::Utils.build_query(env["rack.request.query_hash"])

        qs = env["QUERY_STRING"]
        request_uri = (env["PATH_INFO"] || "").dup
        request_uri << "?" + qs unless qs == ""
        env["REQUEST_URI"] = request_uri
      end

      def realm_url(req)
        url = req.scheme + "://"
        url << req.host

        scheme, port = req.scheme, req.port
        if scheme == "https" && port != 443 ||
            scheme == "http" && port != 80
          url << ":#{port}"
        end

        url
      end

      def request_url(req)
        url = realm_url(req)
        url << req.script_name
        url << req.path_info
        url << "?#{req.query_string}" if req.query_string.to_s.length > 0
        url
      end

      def redirect_to(url)
        [303, {"Content-Type" => "text/html", "Location" => url}, []]
      end

      def open_id_redirect_url(req, oidreq, trust_root, return_to, method, immediate)
        request_url = request_url(req)

        if return_to
          method ||= "get"
        else
          return_to = request_url
          method ||= req.request_method
        end

        method = method.to_s.downcase
        oidreq.return_to_args['_method'] = method unless method == "get"
        oidreq.redirect_url(trust_root || realm_url(req), return_to || request_url, immediate)
      end

      def add_simple_registration_fields(oidreq, fields)
        sregreq = ::OpenID::SReg::Request.new

        required = Array(fields['required']).reject(&URL_FIELD_SELECTOR)
        sregreq.request_fields(required, true) if required.any?

        optional = Array(fields['optional']).reject(&URL_FIELD_SELECTOR)
        sregreq.request_fields(optional, false) if optional.any?

        policy_url = fields['policy_url']
        sregreq.policy_url = policy_url if policy_url

        oidreq.add_extension(sregreq)
      end

      def add_attribute_exchange_fields(oidreq, fields)
        axreq = ::OpenID::AX::FetchRequest.new

        required = Array(fields['required']).select(&URL_FIELD_SELECTOR)
        optional = Array(fields['optional']).select(&URL_FIELD_SELECTOR)

        if required.any? || optional.any?
          required.each do |field|
            axreq.add(::OpenID::AX::AttrInfo.new(field, nil, true))
          end

          optional.each do |field|
            axreq.add(::OpenID::AX::AttrInfo.new(field, nil, false))
          end

          oidreq.add_extension(axreq)
        end
      end

      def add_oauth_fields(oidreq, fields)
        if (consumer = fields['oauth[consumer]']) &&
              (scope = fields['oauth[scope]'])
          oauthreq = ::OpenID::OAuth::Request.new(consumer, Array(scope).join(' '))
          oidreq.add_extension(oauthreq)
        end
      end

      def default_store
        require 'openid/store/memory'
        ::OpenID::Store::Memory.new
      end

      def timeout_protection_from_identity_server
        yield
      rescue Timeout::Error
        TimeoutResponse.new
      end
  end
end
