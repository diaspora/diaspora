require 'faraday'

module OAuth2
  class Client
    attr_accessor :id, :secret, :site, :connection, :options, :raise_errors, :token_method
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
    # <tt>:access_token_method</tt> :: Specify the method to use for token endpoints, can be :get or :post
    # (note: for Facebook this should be :get and for Google this should be :post)
    # <tt>:access_token_url</tt> :: Specify the full URL of the access token endpoint.
    # <tt>:parse_json</tt> :: If true, <tt>application/json</tt> responses will be automatically parsed.
    # <tt>:ssl</tt> :: Specify SSL options for the connection.
    # <tt>:adapter</tt> :: The name of the Faraday::Adapter::* class to use, e.g. :net_http. To pass arguments
    # to the adapter pass an array here, e.g. [:action_dispatch, my_test_session]
    # <tt>:raise_errors</tt> :: Default true. When false it will then return the error status and response instead of raising an exception.
    def initialize(client_id, client_secret, opts={})
      self.options      = opts.dup
      self.token_method = self.options.delete(:access_token_method) || :post
      adapter           = self.options.delete(:adapter)
      ssl_opts          = self.options.delete(:ssl) || {}
      connection_opts   = ssl_opts ? {:ssl => ssl_opts} : {}
      self.id           = client_id
      self.secret       = client_secret
      self.site         = self.options.delete(:site) if self.options[:site]
      self.connection   = Faraday::Connection.new(site, connection_opts)
      self.json         = self.options.delete(:parse_json)
      self.raise_errors = !(self.options.delete(:raise_errors) == false)

      if adapter && adapter != :test
        connection.build do |b|
          b.adapter(*[adapter].flatten)
        end
      end
    end

    def authorize_url(params=nil)
      path = options[:authorize_url] || options[:authorize_path] || "/oauth/authorize"
      connection.build_url(path, params).to_s
    end

    def access_token_url(params=nil)
      path = options[:access_token_url] || options[:access_token_path] || "/oauth/access_token"
      connection.build_url(path, params).to_s
    end

    # Makes a request relative to the specified site root.
    def request(verb, url, params={}, headers={})
      if (verb == :get) || (verb == :delete)
        resp = connection.run_request(verb, url, nil, headers) do |req|
          req.params.update(params)
        end
      else
        resp = connection.run_request(verb, url, params, headers)
      end

      if raise_errors
        case resp.status
          when 200...299
            return response_for(resp)
          when 302
            return request(verb, resp.headers['location'], params, headers)
          when 401
            e = OAuth2::AccessDenied.new("Received HTTP 401 during request.")
            e.response = resp
            raise e
          when 409
            e = OAuth2::Conflict.new("Received HTTP 409 during request.")
            e.response = resp
            raise e
          else
            e = OAuth2::HTTPError.new("Received HTTP #{resp.status} during request.")
            e.response = resp
            raise e
        end
      else
        response_for resp
      end
    end

    def json?; !!@json end

    def web_server; OAuth2::Strategy::WebServer.new(self) end
    def password; OAuth2::Strategy::Password.new(self) end

    private

    def response_for(resp)
      if json?
        return ResponseObject.from(resp)
      else
        return ResponseString.new(resp)
      end
    end
  end
end
