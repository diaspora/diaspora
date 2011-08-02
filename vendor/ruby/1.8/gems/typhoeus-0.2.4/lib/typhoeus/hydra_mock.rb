module Typhoeus
  class HydraMock
    attr_reader :url, :method, :requests, :uri

    def initialize(url, method, options = {})
      @url      = url
      @uri      = URI.parse(url) if url.kind_of?(String)
      @method   = method
      @requests = []
      @options = options
      if @options[:headers]
        @options[:headers] = Typhoeus::NormalizedHeaderHash.new(@options[:headers])
      end

      @current_response_index = 0
    end

    def body
      @options[:body]
    end

    def body?
      @options.has_key?(:body)
    end

    def headers
      @options[:headers]
    end

    def headers?
      @options.has_key?(:headers)
    end

    def add_request(request)
      @requests << request
    end

    def and_return(val)
      if val.respond_to?(:each)
        @responses = val
      else
        @responses = [val]
      end

      # make sure to mark them as a mock.
      @responses.each { |r| r.mock = true }

      val
    end

    def response
      if @current_response_index == (@responses.length - 1)
        @responses.last
      else
        value = @responses[@current_response_index]
        @current_response_index += 1
        value
      end
    end

    def matches?(request)
      if !method_matches?(request) or !url_matches?(request)
        return false
      end

      if body?
        return false unless body_matches?(request)
      end

      if headers?
        return false unless headers_match?(request)
      end

      true
    end

  private
    def method_matches?(request)
      self.method == :any or self.method == request.method
    end

    def url_matches?(request)
      if url.kind_of?(String)
        request_uri = URI.parse(request.url)
        request_uri == self.uri
      else
        self.url =~ request.url
      end
    end

    def body_matches?(request)
      !request.body.nil? && !request.body.empty? && request.body == self.body
    end

    def headers_match?(request)
      request_headers = NormalizedHeaderHash.new(request.headers)

      if empty_headers?(self.headers)
        empty_headers?(request_headers)
      else
        return false if empty_headers?(request_headers)

        headers.each do |key, value|
          return false unless header_value_matches?(value, request_headers[key])
        end

        true
      end
    end

    def header_value_matches?(mock_value, request_value)
      mock_arr = mock_value.is_a?(Array) ? mock_value : [mock_value]
      request_arr = request_value.is_a?(Array) ? request_value : [request_value]

      return false unless mock_arr.size == request_arr.size
      mock_arr.all? do |value|
        request_arr.any? { |a| value === a }
      end
    end

    def empty_headers?(headers)
      # We consider the default User-Agent header to be empty since
      # Typhoeus always adds that.
      headers.nil? || headers.empty? || default_typhoeus_headers?(headers)
    end

    def default_typhoeus_headers?(headers)
      headers.size == 1 && headers['User-Agent'] == Typhoeus::USER_AGENT
    end
  end
end
