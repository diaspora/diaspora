require 'tempfile'
require 'stringio'
require 'strscan'

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/access'
require 'action_dispatch/http/headers'

module ActionDispatch
  class Request < Rack::Request
    include ActionDispatch::Http::Cache::Request
    include ActionDispatch::Http::MimeNegotiation
    include ActionDispatch::Http::Parameters
    include ActionDispatch::Http::FilterParameters
    include ActionDispatch::Http::Upload
    include ActionDispatch::Http::URL

    LOCALHOST = [/^127\.0\.0\.\d{1,3}$/, "::1", /^0:0:0:0:0:0:0:1(%.*)?$/].freeze

    %w[ AUTH_TYPE GATEWAY_INTERFACE
        PATH_TRANSLATED REMOTE_HOST
        REMOTE_IDENT REMOTE_USER REMOTE_ADDR
        SERVER_NAME SERVER_PROTOCOL

        HTTP_ACCEPT HTTP_ACCEPT_CHARSET HTTP_ACCEPT_ENCODING
        HTTP_ACCEPT_LANGUAGE HTTP_CACHE_CONTROL HTTP_FROM
        HTTP_NEGOTIATE HTTP_PRAGMA ].each do |env|
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{env.sub(/^HTTP_/n, '').downcase}
          @env["#{env}"]
        end
      METHOD
    end

    def self.new(env)
      if request = env["action_dispatch.request"] && request.instance_of?(self)
        return request
      end

      super
    end

    def key?(key)
      @env.key?(key)
    end

    HTTP_METHODS = %w(get head put post delete options)
    HTTP_METHOD_LOOKUP = HTTP_METHODS.inject({}) { |h, m| h[m] = h[m.upcase] = m.to_sym; h }

    # Returns the HTTP \method that the application should see.
    # In the case where the \method was overridden by a middleware
    # (for instance, if a HEAD request was converted to a GET,
    # or if a _method parameter was used to determine the \method
    # the application should use), this \method returns the overridden
    # value, not the original.
    def request_method
      @request_method ||= begin
        method = env["REQUEST_METHOD"]
        HTTP_METHOD_LOOKUP[method] || raise(ActionController::UnknownHttpMethod, "#{method}, accepted HTTP methods are #{HTTP_METHODS.to_sentence(:locale => :en)}")
        method
      end
    end

    # Returns a symbol form of the #request_method
    def request_method_symbol
      HTTP_METHOD_LOOKUP[request_method]
    end

    # Returns the original value of the environment's REQUEST_METHOD,
    # even if it was overridden by middleware. See #request_method for
    # more information.
    def method
      @method ||= begin
        method = env["rack.methodoverride.original_method"] || env['REQUEST_METHOD']
        HTTP_METHOD_LOOKUP[method] || raise(ActionController::UnknownHttpMethod, "#{method}, accepted HTTP methods are #{HTTP_METHODS.to_sentence(:locale => :en)}")
        method
      end
    end

    # Returns a symbol form of the #method
    def method_symbol
      HTTP_METHOD_LOOKUP[method]
    end

    # Is this a GET (or HEAD) request?
    # Equivalent to <tt>request.request_method == :get</tt>.
    def get?
      HTTP_METHOD_LOOKUP[request_method] == :get
    end

    # Is this a POST request?
    # Equivalent to <tt>request.request_method == :post</tt>.
    def post?
      HTTP_METHOD_LOOKUP[request_method] == :post
    end

    # Is this a PUT request?
    # Equivalent to <tt>request.request_method == :put</tt>.
    def put?
      HTTP_METHOD_LOOKUP[request_method] == :put
    end

    # Is this a DELETE request?
    # Equivalent to <tt>request.request_method == :delete</tt>.
    def delete?
      HTTP_METHOD_LOOKUP[request_method] == :delete
    end

    # Is this a HEAD request?
    # Equivalent to <tt>request.method == :head</tt>.
    def head?
      HTTP_METHOD_LOOKUP[method] == :head
    end

    # Provides access to the request's HTTP headers, for example:
    #
    #   request.headers["Content-Type"] # => "text/plain"
    def headers
      Http::Headers.new(@env)
    end

    def fullpath
      @fullpath ||= super
    end

    def forgery_whitelisted?
      get? || xhr? || content_mime_type.nil? || !content_mime_type.verify_request?
    end

    def media_type
      content_mime_type.to_s
    end

    # Returns the content length of the request as an integer.
    def content_length
      super.to_i
    end

    # Returns true if the request's "X-Requested-With" header contains
    # "XMLHttpRequest". (The Prototype Javascript library sends this header with
    # every Ajax request.)
    def xml_http_request?
      !(@env['HTTP_X_REQUESTED_WITH'] !~ /XMLHttpRequest/i)
    end
    alias :xhr? :xml_http_request?

    def ip
      @ip ||= super
    end

    # Which IP addresses are "trusted proxies" that can be stripped from
    # the right-hand-side of X-Forwarded-For
    TRUSTED_PROXIES = /^127\.0\.0\.1$|^(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\./i

    # Determines originating IP address.  REMOTE_ADDR is the standard
    # but will fail if the user is behind a proxy.  HTTP_CLIENT_IP and/or
    # HTTP_X_FORWARDED_FOR are set by proxies so check for these if
    # REMOTE_ADDR is a proxy.  HTTP_X_FORWARDED_FOR may be a comma-
    # delimited list in the case of multiple chained proxies; the last
    # address which is not trusted is the originating IP.
    def remote_ip
      @remote_ip ||= (@env["action_dispatch.remote_ip"] || ip).to_s
    end

    # Returns the lowercase name of the HTTP server software.
    def server_software
      (@env['SERVER_SOFTWARE'] && /^([a-zA-Z]+)/ =~ @env['SERVER_SOFTWARE']) ? $1.downcase : nil
    end

    # Read the request \body. This is useful for web services that need to
    # work with raw requests directly.
    def raw_post
      unless @env.include? 'RAW_POST_DATA'
        @env['RAW_POST_DATA'] = body.read(@env['CONTENT_LENGTH'].to_i)
        body.rewind if body.respond_to?(:rewind)
      end
      @env['RAW_POST_DATA']
    end

    # The request body is an IO input stream. If the RAW_POST_DATA environment
    # variable is already set, wrap it in a StringIO.
    def body
      if raw_post = @env['RAW_POST_DATA']
        raw_post.force_encoding(Encoding::BINARY) if raw_post.respond_to?(:force_encoding)
        StringIO.new(raw_post)
      else
        @env['rack.input']
      end
    end

    def form_data?
      FORM_DATA_MEDIA_TYPES.include?(content_mime_type.to_s)
    end

    def body_stream #:nodoc:
      @env['rack.input']
    end

    # TODO This should be broken apart into AD::Request::Session and probably
    # be included by the session middleware.
    def reset_session
      session.destroy if session
      self.session = {}
      @env['action_dispatch.request.flash_hash'] = nil
    end

    def session=(session) #:nodoc:
      @env['rack.session'] = session
    end

    def session_options=(options)
      @env['rack.session.options'] = options
    end

    # Override Rack's GET method to support indifferent access
    def GET
      @env["action_dispatch.request.query_parameters"] ||= normalize_parameters(super)
    end
    alias :query_parameters :GET

    # Override Rack's POST method to support indifferent access
    def POST
      @env["action_dispatch.request.request_parameters"] ||= normalize_parameters(super)
    end
    alias :request_parameters :POST


    # Returns the authorization header regardless of whether it was specified directly or through one of the
    # proxy alternatives.
    def authorization
      @env['HTTP_AUTHORIZATION']   ||
      @env['X-HTTP_AUTHORIZATION'] ||
      @env['X_HTTP_AUTHORIZATION'] ||
      @env['REDIRECT_X_HTTP_AUTHORIZATION']
    end

    # True if the request came from localhost, 127.0.0.1.
    def local?
      LOCALHOST.any? { |local_ip| local_ip === remote_addr && local_ip === remote_ip }
    end
  end
end
