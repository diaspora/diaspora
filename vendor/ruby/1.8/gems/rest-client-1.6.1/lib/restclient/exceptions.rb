module RestClient

  STATUSES = {100 => 'Continue',
              101 => 'Switching Protocols',
              102 => 'Processing', #WebDAV

              200 => 'OK',
              201 => 'Created',
              202 => 'Accepted',
              203 => 'Non-Authoritative Information', # http/1.1
              204 => 'No Content',
              205 => 'Reset Content',
              206 => 'Partial Content',
              207 => 'Multi-Status', #WebDAV

              300 => 'Multiple Choices',
              301 => 'Moved Permanently',
              302 => 'Found',
              303 => 'See Other', # http/1.1
              304 => 'Not Modified',
              305 => 'Use Proxy', # http/1.1
              306 => 'Switch Proxy', # no longer used
              307 => 'Temporary Redirect', # http/1.1
              
              400 => 'Bad Request',
              401 => 'Unauthorized',
              402 => 'Payment Required',
              403 => 'Forbidden',
              404 => 'Resource Not Found',
              405 => 'Method Not Allowed',
              406 => 'Not Acceptable',
              407 => 'Proxy Authentication Required',
              408 => 'Request Timeout',
              409 => 'Conflict',
              410 => 'Gone',
              411 => 'Length Required',
              412 => 'Precondition Failed',
              413 => 'Request Entity Too Large',
              414 => 'Request-URI Too Long',
              415 => 'Unsupported Media Type',
              416 => 'Requested Range Not Satisfiable',
              417 => 'Expectation Failed',
              418 => 'I\'m A Teapot',
              421 => 'Too Many Connections From This IP',
              422 => 'Unprocessable Entity', #WebDAV
              423 => 'Locked', #WebDAV
              424 => 'Failed Dependency', #WebDAV
              425 => 'Unordered Collection', #WebDAV
              426 => 'Upgrade Required', 
              449 => 'Retry With', #Microsoft
              450 => 'Blocked By Windows Parental Controls', #Microsoft

              500 => 'Internal Server Error',
              501 => 'Not Implemented',
              502 => 'Bad Gateway',
              503 => 'Service Unavailable',
              504 => 'Gateway Timeout',
              505 => 'HTTP Version Not Supported',
              506 => 'Variant Also Negotiates',
              507 => 'Insufficient Storage', #WebDAV
              509 => 'Bandwidth Limit Exceeded', #Apache
              510 => 'Not Extended'}

  # Compatibility : make the Response act like a Net::HTTPResponse when needed
  module ResponseForException
    def method_missing symbol, *args
      if net_http_res.respond_to? symbol
        warn "[warning] The response contained in an RestClient::Exception is now a RestClient::Response instead of a Net::HTTPResponse, please update your code"
        net_http_res.send symbol, *args
      else
        super
      end
    end
  end

  # This is the base RestClient exception class. Rescue it if you want to
  # catch any exception that your request might raise
  # You can get the status code by e.http_code, or see anything about the
  # response via e.response.
  # For example, the entire result body (which is
  # probably an HTML error page) is e.response.
  class Exception < RuntimeError
    attr_accessor :message, :response

    def initialize response = nil, initial_response_code = nil
      @response = response
      @initial_response_code = initial_response_code

      # compatibility: this make the exception behave like a Net::HTTPResponse
      response.extend ResponseForException if response
    end

    def http_code
      # return integer for compatibility
      if @response
        @response.code.to_i
      else
        @initial_response_code
      end
    end

    def http_body
      @response.body if @response
    end

    def inspect
      "#{message}: #{http_body}"
    end

    def to_s
      inspect
    end

  end

  # Compatibility
  class ExceptionWithResponse < Exception
  end

  # The request failed with an error code not managed by the code
  class RequestFailed < ExceptionWithResponse

    def message
      "HTTP status code #{http_code}"
    end

    def to_s
      message
    end
  end

  # We will a create an exception for each status code, see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
  module Exceptions
    # Map http status codes to the corresponding exception class
    EXCEPTIONS_MAP = {}
  end

  STATUSES.each_pair do |code, message|

    # Compatibility
    superclass = ([304, 401, 404].include? code) ? ExceptionWithResponse : RequestFailed
    klass = Class.new(superclass) do
      send(:define_method, :message) {"#{http_code ? "#{http_code} " : ''}#{message}"}
    end
    klass_constant = const_set message.delete(' \-\''), klass
    Exceptions::EXCEPTIONS_MAP[code] = klass_constant
  end

  # A redirect was encountered; caught by execute to retry with the new url.
  class Redirect < Exception

    message = 'Redirect'

    attr_accessor :url

    def initialize(url)
      @url = url
    end
  end

  # The server broke the connection prior to the request completing.  Usually
  # this means it crashed, or sometimes that your network connection was
  # severed before it could complete.
  class ServerBrokeConnection < Exception
    message = 'Server broke connection'
  end

  class SSLCertificateNotVerified < Exception
    def initialize(message)
      super nil, nil
      self.message = message
    end
  end
end

# backwards compatibility
class RestClient::Request
  Redirect = RestClient::Redirect
  Unauthorized = RestClient::Unauthorized
  RequestFailed = RestClient::RequestFailed
end
