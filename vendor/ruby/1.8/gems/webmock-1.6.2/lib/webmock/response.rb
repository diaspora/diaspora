#compatibility with Ruby 1.9.2 preview1 to allow reading raw responses
class StringIO
  alias_method :read_nonblock, :sysread
end

module WebMock

  class ResponseFactory
    def self.response_for(options)
      if options.respond_to?(:call)
        WebMock::DynamicResponse.new(options)
      else
        WebMock::Response.new(options)
      end
    end
  end

  class Response
    def initialize(options = {})
      if options.is_a?(IO) || options.is_a?(String)
        self.options = read_raw_response(options)
      else
        self.options = options
      end
    end

    def headers
      @headers
    end

    def headers=(headers)
      @headers = headers
      if @headers && !@headers.is_a?(Proc)
        @headers = Util::Headers.normalize_headers(@headers)
      end
    end

    def body
      @body || ''
    end

    def body=(body)
      @body = body
      stringify_body!
    end

    def status
      @status || [200, ""]
    end

    def status=(status)
      @status = status.is_a?(Integer) ? [status, ""] : status
    end

    def exception
      @exception
    end

    def exception=(exception)
      @exception = case exception
      when String then StandardError.new(exception)
      when Class then exception.new('Exception from WebMock')
      when Exception then exception
      end
    end

    def raise_error_if_any
      raise @exception if @exception
    end

    def should_timeout
      @should_timeout == true
    end

    def options=(options)
      self.headers = options[:headers]
      self.status = options[:status]
      self.body = options[:body]
      self.exception = options[:exception]
      @should_timeout = options[:should_timeout]
    end

    def evaluate(request_signature)
      self.body = @body.call(request_signature) if @body.is_a?(Proc)
      self.headers = @headers.call(request_signature) if @headers.is_a?(Proc)
      self.status = @status.call(request_signature) if @status.is_a?(Proc)
      @should_timeout = @should_timeout.call(request_signature) if @should_timeout.is_a?(Proc)
      @exception = @exception.call(request_signature) if @exception.is_a?(Proc)
      self
    end

    def ==(other)
      self.body == other.body &&
      self.headers === other.headers &&
      self.status == other.status &&
      self.exception == other.exception &&
      self.should_timeout == other.should_timeout
    end

    private

    def stringify_body!
      if @body.is_a?(IO)
        io = @body
        @body = io.read
        io.close
      end
    end

    def read_raw_response(raw_response)
      if raw_response.is_a?(IO)
        string = raw_response.read
        raw_response.close
        raw_response = string
      end
      socket = ::Net::BufferedIO.new(raw_response)
      response = ::Net::HTTPResponse.read_new(socket)
      transfer_encoding = response.delete('transfer-encoding') #chunks were already read by curl
      response.reading_body(socket, true) {}

      options = {}
      options[:headers] = {}
      response.each_header {|name, value| options[:headers][name] = value}
      options[:headers]['transfer-encoding'] = transfer_encoding if transfer_encoding
      options[:body] = response.read_body
      options[:status] = [response.code.to_i, response.message]
      options
    end

  end

  class DynamicResponse < Response
    attr_accessor :responder

    def initialize(responder)
      @responder = responder
    end

    def evaluate(request_signature)
      options = @responder.call(request_signature)
      Response.new(options)
    end
  end
end
