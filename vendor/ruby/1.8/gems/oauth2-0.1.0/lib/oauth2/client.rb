require 'faraday'

module OAuth2
  class Client
    class << self
      def default_connection_adapter
        warn '[DEPRECATED] OAuth2::Client#default_connection_adapter is deprecated, use Faraday.default_adapter instead. Will be removed in 0.1.0'
        Faraday.default_adapter
      end

      def default_connection_adapter=(adapter)
        warn '[DEPRECATED] OAuth2::Client#default_connection_adapter is deprecated, use Faraday.default_adapter instead. Will be removed in 0.1.0'
        Faraday.default_adapter = adapter
      end
    end

    attr_accessor :id, :secret, :site, :connection, :options
    attr_writer :json

    # Instantiate a new OAuth 2.0 client using the
    # client ID and client secret registered to your
    # application.
    #
    # Options:
    #
    # <tt>:site</tt> :: Specify a base URL for your OAuth 2.0 client.
    # <tt>:authorize_path</tt> :: Specify the path to the authorization endpoint.
    # <tt>:authorize_url</tt> :: Specify a full URL of the authorization endpoint.
    # <tt>:access_token_path</tt> :: Specify the path to the access token endpoint.
    # <tt>:access_token_url</tt> :: Specify the full URL of the access token endpoint.
    # <tt>:parse_json</tt> :: If true, <tt>application/json</tt> responses will be automatically parsed.
    def initialize(client_id, client_secret, opts = {})
      adapter         = opts.delete(:adapter)
      self.id         = client_id
      self.secret     = client_secret
      self.site       = opts.delete(:site) if opts[:site]
      self.options    = opts
      self.connection = Faraday::Connection.new(site)
      self.json       = opts.delete(:parse_json)

      if adapter && adapter != :test
        connection.build { |b| b.adapter(adapter) }
      end
    end

    def authorize_url(params = nil)
      path = options[:authorize_url] || options[:authorize_path] || "/oauth/authorize"
      connection.build_url(path, params).to_s
    end

    def access_token_url(params = nil)
      path = options[:access_token_url] || options[:access_token_path] || "/oauth/access_token"
      connection.build_url(path, params).to_s
    end

    # Makes a request relative to the specified site root.
    def request(verb, url, params = {}, headers = {})
      if verb == :get
        resp = connection.run_request(verb, url, nil, headers) do |req|
          req.params.update(params)
        end
      else
        resp = connection.run_request(verb, url, params, headers)
      end
      
      case resp.status
        when 200...201
          if json?
            return ResponseObject.from(resp)
          else
            return ResponseString.new(resp)
          end
        when 401
          e = OAuth2::AccessDenied.new("Received HTTP 401 during request.")
          e.response = resp
          raise e
        else
          e = OAuth2::HTTPError.new("Received HTTP #{resp.status} during request.")
          e.response = resp
          raise e
      end
    end

    def json?; !!@json end

    def web_server; OAuth2::Strategy::WebServer.new(self) end
  end
end
