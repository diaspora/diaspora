module Faraday
  # Used to setup urls, params, headers, and the request body in a sane manner.
  #
  #   @connection.post do |req|
  #     req.url 'http://localhost', 'a' => '1' # 'http://localhost?a=1'
  #     req.headers['b'] = '2' # Header
  #     req.params['c']  = '3' # GET Param
  #     req['b']         = '2' # also Header
  #     req.body = 'abc'
  #   end
  #
  class Request < Struct.new(:path, :params, :headers, :body)
    extend AutoloadHelper

    autoload_all 'faraday/request',
      :JSON       => 'json',
      :UrlEncoded => 'url_encoded',
      :Multipart  => 'multipart'

    register_lookup_modules \
      :json        => :JSON,
      :url_encoded => :UrlEncoded,
      :multipart   => :Multipart

    def self.run(connection, request_method)
      req = create
      yield req if block_given?
      req.run(connection, request_method)
    end

    def self.create
      req = new(nil, {}, {}, nil)
      yield req if block_given?
      req
    end

    def url(path, params = {})
      self.path   = path
      self.params = params
    end

    def [](key)
      headers[key]
    end

    def []=(key, value)
      headers[key] = value
    end

    # ENV Keys
    # :method - a symbolized request method (:get, :post)
    # :body   - the request body that will eventually be converted to a string.
    # :url    - Addressable::URI instance of the URI for the current request.
    # :status           - HTTP response status code
    # :request_headers  - hash of HTTP Headers to be sent to the server
    # :response_headers - Hash of HTTP headers from the server
    # :parallel_manager - sent if the connection is in parallel mode
    # :request - Hash of options for configuring the request.
    #   :timeout      - open/read timeout Integer in seconds
    #   :open_timeout - read timeout Integer in seconds
    #   :proxy        - Hash of proxy options
    #     :uri        - Proxy Server URI
    #     :user       - Proxy server username
    #     :password   - Proxy server password
    # :ssl - Hash of options for configuring SSL requests.
    def to_env_hash(connection, request_method)
      env_headers = connection.headers.dup
      env_params  = connection.params.dup
      connection.merge_headers(env_headers, headers)
      connection.merge_params(env_params,  params)

      { :method           => request_method,
        :body             => body,
        :url              => connection.build_url(path, env_params),
        :request_headers  => env_headers,
        :parallel_manager => connection.parallel_manager,
        :request          => connection.options.merge(:proxy => connection.proxy),
        :ssl              => connection.ssl}
    end

    def run(connection, request_method)
      app = lambda { |env|
        response = Response.new
        response.finish(env) unless env[:parallel_manager]
        env[:response] = response
      }
      env = to_env_hash(connection, request_method)
      connection.builder.to_app(app).call(env)
    end
  end
end
