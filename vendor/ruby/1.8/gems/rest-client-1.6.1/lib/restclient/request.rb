require 'tempfile'
require 'mime/types'
require 'cgi'

module RestClient
  # This class is used internally by RestClient to send the request, but you can also
  # call it directly if you'd like to use a method not supported by the
  # main API.  For example:
  #
  #   RestClient::Request.execute(:method => :head, :url => 'http://example.com')
  #
  # Mandatory parameters:
  # * :method
  # * :url
  # Optional parameters (have a look at ssl and/or uri for some explanations):
  # * :headers a hash containing the request headers
  # * :cookies will replace possible cookies in the :headers
  # * :user and :password for basic auth, will be replaced by a user/password available in the :url
  # * :raw_response return a low-level RawResponse instead of a Response
  # * :verify_ssl enable ssl verification, possible values are constants from OpenSSL::SSL
  # * :timeout and :open_timeout
  # * :ssl_client_cert, :ssl_client_key, :ssl_ca_file
  class Request

    attr_reader :method, :url, :headers, :cookies,
                :payload, :user, :password, :timeout,
                :open_timeout, :raw_response, :verify_ssl, :ssl_client_cert,
                :ssl_client_key, :ssl_ca_file, :processed_headers, :args

    def self.execute(args, & block)
      new(args).execute(& block)
    end

    def initialize args
      @method = args[:method] or raise ArgumentError, "must pass :method"
      @headers = args[:headers] || {}
      if args[:url]
        @url = process_get_params(args[:url], headers)
      else
        raise ArgumentError, "must pass :url"
      end
      @cookies = @headers.delete(:cookies) || args[:cookies] || {}
      @payload = Payload.generate(args[:payload])
      @user = args[:user]
      @password = args[:password]
      @timeout = args[:timeout]
      @open_timeout = args[:open_timeout]
      @raw_response = args[:raw_response] || false
      @verify_ssl = args[:verify_ssl] || false
      @ssl_client_cert = args[:ssl_client_cert] || nil
      @ssl_client_key = args[:ssl_client_key] || nil
      @ssl_ca_file = args[:ssl_ca_file] || nil
      @tf = nil # If you are a raw request, this is your tempfile
      @processed_headers = make_headers headers
      @args = args
    end

    def execute & block
      uri = parse_url_with_auth(url)
      transmit uri, net_http_request_class(method).new(uri.request_uri, processed_headers), payload, & block
    end

    # Extract the query parameters for get request and append them to the url
    def process_get_params url, headers
      if [:get, :head].include? method
        get_params = {}
        headers.delete_if do |key, value|
          if 'params' == key.to_s.downcase && value.is_a?(Hash)
            get_params.merge! value
            true
          else
            false
          end
        end
        unless get_params.empty?
          query_string = get_params.collect { |k, v| "#{k.to_s}=#{CGI::escape(v.to_s)}" }.join('&')
          url + "?#{query_string}"
        else
          url
        end
      else
        url
      end
    end

    def make_headers user_headers
      unless @cookies.empty?
        user_headers[:cookie] = @cookies.map { |(key, val)| "#{key.to_s}=#{CGI::unescape(val)}" }.sort.join(';')
      end
      headers = stringify_headers(default_headers).merge(stringify_headers(user_headers))
      headers.merge!(@payload.headers) if @payload
      headers
    end

    def net_http_class
      if RestClient.proxy
        proxy_uri = URI.parse(RestClient.proxy)
        Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
      else
        Net::HTTP
      end
    end

    def net_http_request_class(method)
      Net::HTTP.const_get(method.to_s.capitalize)
    end

    def parse_url(url)
      url = "http://#{url}" unless url.match(/^http/)
      URI.parse(url)
    end

    def parse_url_with_auth(url)
      uri = parse_url(url)
      @user = CGI.unescape(uri.user) if uri.user
      @password = CGI.unescape(uri.password) if uri.password
      uri
    end

    def process_payload(p=nil, parent_key=nil)
      unless p.is_a?(Hash)
        p
      else
        @headers[:content_type] ||= 'application/x-www-form-urlencoded'
        p.keys.map do |k|
          key = parent_key ? "#{parent_key}[#{k}]" : k
          if p[k].is_a? Hash
            process_payload(p[k], key)
          else
            value = URI.escape(p[k].to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
            "#{key}=#{value}"
          end
        end.join("&")
      end
    end

    def transmit uri, req, payload, & block
      setup_credentials req

      net = net_http_class.new(uri.host, uri.port)
      net.use_ssl = uri.is_a?(URI::HTTPS)
      if @verify_ssl == false
        net.verify_mode = OpenSSL::SSL::VERIFY_NONE
      elsif @verify_ssl.is_a? Integer
        net.verify_mode = @verify_ssl
        net.verify_callback = lambda do |preverify_ok, ssl_context|
          if (!preverify_ok) || ssl_context.error != 0
            err_msg = "SSL Verification failed -- Preverify: #{preverify_ok}, Error: #{ssl_context.error_string} (#{ssl_context.error})"
            raise SSLCertificateNotVerified.new(err_msg)
          end
          true
        end
      end
      net.cert = @ssl_client_cert if @ssl_client_cert
      net.key = @ssl_client_key if @ssl_client_key
      net.ca_file = @ssl_ca_file if @ssl_ca_file
      net.read_timeout = @timeout if @timeout
      net.open_timeout = @open_timeout if @open_timeout

      RestClient.before_execution_procs.each do |before_proc|
        before_proc.call(req, args)
      end

      log_request

      net.start do |http|
        res = http.request(req, payload) { |http_response| fetch_body(http_response) }
        log_response res
        process_result res, & block
      end
    rescue EOFError
      raise RestClient::ServerBrokeConnection
    rescue Timeout::Error
      raise RestClient::RequestTimeout
    end

    def setup_credentials(req)
      req.basic_auth(user, password) if user
    end

    def fetch_body(http_response)
      if @raw_response
        # Taken from Chef, which as in turn...
        # Stolen from http://www.ruby-forum.com/topic/166423
        # Kudos to _why!
        @tf = Tempfile.new("rest-client")
        size, total = 0, http_response.header['Content-Length'].to_i
        http_response.read_body do |chunk|
          @tf.write chunk
          size += chunk.size
          if RestClient.log
            if size == 0
              RestClient.log << "#{@method} #{@url} done (0 length file\n)"
            elsif total == 0
              RestClient.log << "#{@method} #{@url} (zero content length)\n"
            else
              RestClient.log << "#{@method} #{@url} %d%% done (%d of %d)\n" % [(size * 100) / total, size, total]
            end
          end
        end
        @tf.close
        @tf
      else
        http_response.read_body
      end
      http_response
    end

    def process_result res, & block
      if @raw_response
        # We don't decode raw requests
        response = RawResponse.new(@tf, res, args)
      else
        response = Response.create(Request.decode(res['content-encoding'], res.body), res, args)
      end

      if block_given?
        block.call(response, self, res, & block)
      else
        response.return!(self, res, & block)
      end

    end

    def self.decode content_encoding, body
      if (!body) || body.empty?
        body
      elsif content_encoding == 'gzip'
        Zlib::GzipReader.new(StringIO.new(body)).read
      elsif content_encoding == 'deflate'
        Zlib::Inflate.new.inflate body
      else
        body
      end
    end

    def log_request
      if RestClient.log
        out = []
        out << "RestClient.#{method} #{url.inspect}"
        out << payload.short_inspect if payload
        out << processed_headers.to_a.sort.map { |(k, v)| [k.inspect, v.inspect].join("=>") }.join(", ")
        RestClient.log << out.join(', ') + "\n"
      end
    end

    def log_response res
      if RestClient.log
        size = @raw_response ? File.size(@tf.path) : (res.body.nil? ? 0 : res.body.size)
        RestClient.log << "# => #{res.code} #{res.class.to_s.gsub(/^Net::HTTP/, '')} | #{(res['Content-type'] || '').gsub(/;.*$/, '')} #{size} bytes\n"
      end
    end

    # Return a hash of headers whose keys are capitalized strings
    def stringify_headers headers
      headers.inject({}) do |result, (key, value)|
        if key.is_a? Symbol
          key = key.to_s.split(/_/).map { |w| w.capitalize }.join('-')
        end
        if 'CONTENT-TYPE' == key.upcase
          target_value = value.to_s
          result[key] = MIME::Types.type_for_extension target_value
        elsif 'ACCEPT' == key.upcase
          # Accept can be composed of several comma-separated values
          if value.is_a? Array
            target_values = value
          else
            target_values = value.to_s.split ','
          end
          result[key] = target_values.map { |ext| MIME::Types.type_for_extension(ext.to_s.strip) }.join(', ')
        else
          result[key] = value.to_s
        end
        result
      end
    end

    def default_headers
      {:accept => '*/*; q=0.5, application/xml', :accept_encoding => 'gzip, deflate'}
    end

  end
end

module MIME
  class Types

    # Return the first found content-type for a value considered as an extension or the value itself
    def type_for_extension ext
      candidates = @extension_index[ext]
      candidates.empty? ? ext : candidates[0].content_type
    end

    class << self
      def type_for_extension ext
        @__types__.type_for_extension ext
      end
    end
  end
end
