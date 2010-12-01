module HTTParty
  class Request #:nodoc:
    SupportedHTTPMethods = [
      Net::HTTP::Get,
      Net::HTTP::Post,
      Net::HTTP::Put,
      Net::HTTP::Delete,
      Net::HTTP::Head,
      Net::HTTP::Options
    ]

    SupportedURISchemes  = [URI::HTTP, URI::HTTPS]

    attr_accessor :http_method, :path, :options, :last_response, :redirect

    def initialize(http_method, path, o={})
      self.http_method = http_method
      self.path = path
      self.options = {
        :limit => o.delete(:no_follow) ? 1 : 5,
        :default_params => {},
        :parser => Parser
      }.merge(o)
    end

    def path=(uri)
      @path = URI.parse(uri)
    end

    def uri
      new_uri = path.relative? ? URI.parse("#{options[:base_uri]}#{path}") : path

      # avoid double query string on redirects [#12]
      unless redirect
        new_uri.query = query_string(new_uri)
      end

      unless SupportedURISchemes.include? new_uri.class
        raise UnsupportedURIScheme, "'#{new_uri}' Must be HTTP or HTTPS"
      end

      new_uri
    end

    def format
      options[:format] || (format_from_mimetype(last_response['content-type']) if last_response)
    end

    def parser
      options[:parser]
    end

    def perform
      validate
      setup_raw_request
      get_response
      handle_response
    end

    private

    def http
      http = Net::HTTP.new(uri.host, uri.port, options[:http_proxyaddr], options[:http_proxyport])
      http.use_ssl = ssl_implied?

      if options[:timeout] && options[:timeout].is_a?(Integer)
        http.open_timeout = options[:timeout]
        http.read_timeout = options[:timeout]
      end

      if options[:pem] && http.use_ssl?
        http.cert = OpenSSL::X509::Certificate.new(options[:pem])
        http.key = OpenSSL::PKey::RSA.new(options[:pem])
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      else
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      if options[:debug_output]
        http.set_debug_output(options[:debug_output])
      end

      http
    end

    def ssl_implied?
      uri.port == 443 || uri.instance_of?(URI::HTTPS)
    end

    def body
      options[:body].is_a?(Hash) ? options[:body].to_params : options[:body]
    end

    def credentials
      options[:basic_auth] || options[:digest_auth]
    end

    def username
      credentials[:username]
    end

    def password
      credentials[:password]
    end

    def setup_raw_request
      @raw_request = http_method.new(uri.request_uri)
      @raw_request.body = body if body
      @raw_request.initialize_http_header(options[:headers])
      @raw_request.basic_auth(username, password) if options[:basic_auth]
      setup_digest_auth if options[:digest_auth]
    end

    def setup_digest_auth
      res = http.head(uri.request_uri, options[:headers])
      if res['www-authenticate'] != nil && res['www-authenticate'].length > 0
        @raw_request.digest_auth(username, password, res)
      end
    end

    def perform_actual_request
      http.request(@raw_request)
    end

    def get_response
      self.last_response = perform_actual_request
    end

    def query_string(uri)
      query_string_parts = []
      query_string_parts << uri.query unless uri.query.nil?

      if options[:query].is_a?(Hash)
        query_string_parts << options[:default_params].merge(options[:query]).to_params
      else
        query_string_parts << options[:default_params].to_params unless options[:default_params].empty?
        query_string_parts << options[:query] unless options[:query].nil?
      end

      query_string_parts.size > 0 ? query_string_parts.join('&') : nil
    end

    # Raises exception Net::XXX (http error code) if an http error occured
    def handle_response
      handle_deflation
      case last_response
      when Net::HTTPMultipleChoice, # 300
        Net::HTTPMovedPermanently, # 301
        Net::HTTPFound, # 302
        Net::HTTPSeeOther, # 303
        Net::HTTPUseProxy, # 305
        Net::HTTPTemporaryRedirect
        if last_response.key?('location')
          options[:limit] -= 1
          self.path = last_response['location']
          self.redirect = true
          self.http_method = Net::HTTP::Get unless options[:maintain_method_across_redirects]
          capture_cookies(last_response)
          perform
        else
          last_response
        end
      else
        Response.new(last_response, parse_response(last_response.body))
      end
    end

    # Inspired by Ruby 1.9
    def handle_deflation
      case last_response["content-encoding"]
      when "gzip"
        body_io = StringIO.new(last_response.body)
        last_response.body.replace Zlib::GzipReader.new(body_io).read
      when "deflate"
        last_response.body.replace Zlib::Inflate.inflate(last_response.body)
      end
    end

    def parse_response(body)
      parser.call(body, format)
    end

    def capture_cookies(response)
      return unless response['Set-Cookie']
      cookies_hash = HTTParty::CookieHash.new()
      cookies_hash.add_cookies(options[:headers]['Cookie']) if options[:headers] && options[:headers]['Cookie']
      cookies_hash.add_cookies(response['Set-Cookie'])
      options[:headers] ||= {}
      options[:headers]['Cookie'] = cookies_hash.to_cookie_string
    end

    # Uses the HTTP Content-Type header to determine the format of the
    # response It compares the MIME type returned to the types stored in the
    # SupportedFormats hash
    def format_from_mimetype(mimetype)
      if mimetype && parser.respond_to?(:format_from_mimetype)
        parser.format_from_mimetype(mimetype)
      end
    end

      def validate
        raise HTTParty::RedirectionTooDeep.new(last_response), 'HTTP redirects too deep' if options[:limit].to_i <= 0
        raise ArgumentError, 'only get, post, put, delete, head, and options methods are supported' unless SupportedHTTPMethods.include?(http_method)
        raise ArgumentError, ':headers must be a hash' if options[:headers] && !options[:headers].is_a?(Hash)
        raise ArgumentError, 'only one authentication method, :basic_auth or :digest_auth may be used at a time' if options[:basic_auth] && options[:digest_auth]
        raise ArgumentError, ':basic_auth must be a hash' if options[:basic_auth] && !options[:basic_auth].is_a?(Hash)
        raise ArgumentError, ':digest_auth must be a hash' if options[:digest_auth] && !options[:digest_auth].is_a?(Hash)
        raise ArgumentError, ':query must be hash if using HTTP Post' if post? && !options[:query].nil? && !options[:query].is_a?(Hash)
      end

    def post?
      Net::HTTP::Post == http_method
    end
  end
end
