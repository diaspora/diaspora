#
# Copyright (c) 2007-2008 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require "net/https"
require "uri"
require "time"
require "logger"

$:.unshift(File.dirname(__FILE__))
require "net_fix"


module RightHttpConnection #:nodoc:
  module VERSION #:nodoc:
    MAJOR = 1
    MINOR = 2
    TINY  = 4

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end


module Rightscale

=begin rdoc
HttpConnection maintains a persistent HTTP connection to a remote
server.  Each instance maintains its own unique connection to the
HTTP server.  HttpConnection makes a best effort to receive a proper
HTTP response from the server, although it does not guarantee that
this response contains a HTTP Success code.

On low-level errors (TCP/IP errors) HttpConnection invokes a reconnect
and retry algorithm.  Note that although each HttpConnection object
has its own connection to the HTTP server, error handling is shared
across all connections to a server.  For example, if there are three
connections to www.somehttpserver.com, a timeout error on one of those
connections will cause all three connections to break and reconnect.
A connection will not break and reconnect, however, unless a request
becomes active on it within a certain amount of time after the error
(as specified by HTTP_CONNECTION_RETRY_DELAY).  An idle connection will not
break even if other connections to the same server experience errors.

A HttpConnection will retry a request a certain number of times (as
defined by HTTP_CONNNECTION_RETRY_COUNT).  If all the retries fail,
an exception is thrown and all HttpConnections associated with a
server enter a probationary period defined by HTTP_CONNECTION_RETRY_DELAY.
If the user makes a new request subsequent to entering probation,
the request will fail immediately with the same exception thrown
on probation entry.  This is so that if the HTTP server has gone
down, not every subsequent request must wait for a connect timeout
before failing.  After the probation period expires, the internal
state of the HttpConnection is reset and subsequent requests have
the full number of potential reconnects and retries available to
them.
=end

  class HttpConnection

    # Number of times to retry the request after encountering the first error
    HTTP_CONNECTION_RETRY_COUNT   = 3
    # Throw a Timeout::Error if a connection isn't established within this number of seconds
    HTTP_CONNECTION_OPEN_TIMEOUT  = 5
    # Throw a Timeout::Error if no data have been read on this connnection within this number of seconds
    HTTP_CONNECTION_READ_TIMEOUT  = 120
    # Length of the post-error probationary period during which all requests will fail
    HTTP_CONNECTION_RETRY_DELAY   = 15

    #--------------------
    # class methods
    #--------------------
    #
    @@params = {}
    @@params[:http_connection_retry_count]  = HTTP_CONNECTION_RETRY_COUNT
    @@params[:http_connection_open_timeout] = HTTP_CONNECTION_OPEN_TIMEOUT
    @@params[:http_connection_read_timeout] = HTTP_CONNECTION_READ_TIMEOUT
    @@params[:http_connection_retry_delay]  = HTTP_CONNECTION_RETRY_DELAY

    # Query the global (class-level) parameters:
    #
    #  :user_agent => 'www.HostName.com'    # String to report as HTTP User agent
    #  :ca_file    => 'path_to_file'        # Path to a CA certification file in PEM format. The file can contain several CA certificates.  If this parameter isn't set, HTTPS certs won't be verified.
    #  :logger     => Logger object         # If omitted, HttpConnection logs to STDOUT
    #  :exception  => Exception to raise    # The type of exception to raise
    #                                       # if a request repeatedly fails. RuntimeError is raised if this parameter is omitted.
    #  :http_connection_retry_count         # by default == Rightscale::HttpConnection::HTTP_CONNECTION_RETRY_COUNT
    #  :http_connection_open_timeout        # by default == Rightscale::HttpConnection::HTTP_CONNECTION_OPEN_TIMEOUT
    #  :http_connection_read_timeout        # by default == Rightscale::HttpConnection::HTTP_CONNECTION_READ_TIMEOUT
    #  :http_connection_retry_delay         # by default == Rightscale::HttpConnection::HTTP_CONNECTION_RETRY_DELAY
    def self.params
      @@params
    end

    # Set the global (class-level) parameters
    def self.params=(params)
      @@params = params
    end

    #------------------
    # instance methods
    #------------------
    attr_accessor :http
    attr_accessor :server
    attr_accessor :params      # see @@params
    attr_accessor :logger

     # Params hash:
     #  :user_agent => 'www.HostName.com'    # String to report as HTTP User agent
     #  :ca_file    => 'path_to_file'        # A path of a CA certification file in PEM format. The file can contain several CA certificates.
     #  :logger     => Logger object         # If omitted, HttpConnection logs to STDOUT
     #  :exception  => Exception to raise    # The type of exception to raise if a request repeatedly fails. RuntimeError is raised if this parameter is omitted.
     #  :http_connection_retry_count         # by default == Rightscale::HttpConnection.params[:http_connection_retry_count]
     #  :http_connection_open_timeout        # by default == Rightscale::HttpConnection.params[:http_connection_open_timeout]
     #  :http_connection_read_timeout        # by default == Rightscale::HttpConnection.params[:http_connection_read_timeout]
     #  :http_connection_retry_delay         # by default == Rightscale::HttpConnection.params[:http_connection_retry_delay]
     #
    def initialize(params={})
      @params = params
      @params[:http_connection_retry_count]  ||= @@params[:http_connection_retry_count]
      @params[:http_connection_open_timeout] ||= @@params[:http_connection_open_timeout]
      @params[:http_connection_read_timeout] ||= @@params[:http_connection_read_timeout]
      @params[:http_connection_retry_delay]  ||= @@params[:http_connection_retry_delay]
      @http   = nil
      @server = nil
      @logger = get_param(:logger) ||
                (RAILS_DEFAULT_LOGGER if defined?(RAILS_DEFAULT_LOGGER)) ||
                Logger.new(STDOUT)
    end

    def get_param(name)
      @params[name] || @@params[name]
    end

    # Query for the maximum size (in bytes) of a single read from the underlying
    # socket.  For bulk transfer, especially over fast links, this is value is
    # critical to performance.
    def socket_read_size?
      Net::BufferedIO.socket_read_size?
    end

    # Set the maximum size (in bytes) of a single read from the underlying
    # socket.  For bulk transfer, especially over fast links, this is value is
    # critical to performance.
    def socket_read_size=(newsize)
      Net::BufferedIO.socket_read_size=(newsize)
    end

    # Query for the maximum size (in bytes) of a single read from local data
    # sources like files.  This is important, for example, in a streaming PUT of a
    # large buffer.
    def local_read_size?
      Net::HTTPGenericRequest.local_read_size?
    end

    # Set the maximum size (in bytes) of a single read from local data
    # sources like files.  This can be used to tune the performance of, for example,  a streaming PUT of a
    # large buffer.
    def local_read_size=(newsize)
      Net::HTTPGenericRequest.local_read_size=(newsize)
    end

  private
    #--------------
    # Retry state - Keep track of errors on a per-server basis
    #--------------
    @@state = {}  # retry state indexed by server: consecutive error count, error time, and error
    @@eof   = {}

    # number of consecutive errors seen for server, 0 all is ok
    def error_count
      @@state[@server] ? @@state[@server][:count] : 0
    end

    # time of last error for server, nil if all is ok
    def error_time
      @@state[@server] && @@state[@server][:time]
    end

    # message for last error for server, "" if all is ok
    def error_message
      @@state[@server] ? @@state[@server][:message] : ""
    end

    # add an error for a server
    def error_add(message)
      @@state[@server] = { :count => error_count+1, :time => Time.now, :message => message }
    end

    # reset the error state for a server (i.e. a request succeeded)
    def error_reset
      @@state.delete(@server)
    end

    # Error message stuff...
    def banana_message
      return "#{@server} temporarily unavailable: (#{error_message})"
    end

    def err_header
      return "#{self.class.name} :"
    end

      # Adds new EOF timestamp.
      # Returns the number of seconds to wait before new conection retry:
      #  0.5, 1, 2, 4, 8
    def add_eof
      (@@eof[@server] ||= []).unshift Time.now
      0.25 * 2 ** @@eof[@server].size
    end

      # Returns first EOF timestamp or nul if have no EOFs being tracked.
    def eof_time
      @@eof[@server] && @@eof[@server].last
    end

      # Returns true if we are receiving EOFs during last @params[:http_connection_retry_delay] seconds
      # and there were no successful response from server
    def raise_on_eof_exception?
      @@eof[@server].blank? ? false : ( (Time.now.to_i-@params[:http_connection_retry_delay]) > @@eof[@server].last.to_i )
    end

      # Reset a list of EOFs for this server.
      # This is being called when we have got an successful response from server.
    def eof_reset
      @@eof.delete(@server)
    end

    # Detects if an object is 'streamable' - can we read from it, and can we know the size?
    def setup_streaming(request)
      if(request.body && request.body.respond_to?(:read))
        body = request.body
        request.content_length = body.respond_to?(:lstat) ? body.lstat.size : body.size
        request.body_stream = request.body
        true
      end
    end

    def get_fileptr_offset(request_params)
      request_params[:request].body.pos
    rescue Exception => e
      # Probably caught this because the body doesn't support the pos() method, like if it is a socket.
      # Just return 0 and get on with life.
      0
    end

    def reset_fileptr_offset(request, offset = 0)
      if(request.body_stream && request.body_stream.respond_to?(:pos))
        begin
          request.body_stream.pos = offset
        rescue Exception => e
          @logger.warn("Failed file pointer reset; aborting HTTP retries." +
                             " -- #{err_header} #{e.inspect}")
          raise e
        end
      end
    end

    # Start a fresh connection. The object closes any existing connection and
    # opens a new one.
    def start(request_params)
      # close the previous if exists
      finish
      # create new connection
      @server   = request_params[:server]
      @port     = request_params[:port]
      @protocol = request_params[:protocol]

      @logger.info("Opening new #{@protocol.upcase} connection to #@server:#@port")
      @http = Net::HTTP.new(@server, @port)
      @http.open_timeout = @params[:http_connection_open_timeout]
      @http.read_timeout = @params[:http_connection_read_timeout]

      if @protocol == 'https'
        verifyCallbackProc = Proc.new{ |ok, x509_store_ctx|
          code = x509_store_ctx.error
          msg = x509_store_ctx.error_string
            #debugger
          @logger.warn("##### #{@server} certificate verify failed: #{msg}") unless code == 0
          true
        }
        @http.use_ssl = true
        ca_file = get_param(:ca_file)
        if ca_file
          @http.verify_mode     = OpenSSL::SSL::VERIFY_PEER
          @http.verify_callback = verifyCallbackProc
          @http.ca_file         = ca_file
        end
      end
      # open connection
      @http.start
    end

  public

=begin rdoc
    Send HTTP request to server

     request_params hash:
     :server   => 'www.HostName.com'   # Hostname or IP address of HTTP server
     :port     => '80'                 # Port of HTTP server
     :protocol => 'https'              # http and https are supported on any port
     :request  => 'requeststring'      # Fully-formed HTTP request to make

    Raises RuntimeError, Interrupt, and params[:exception] (if specified in new).

=end
    def request(request_params, &block)
      # We save the offset here so that if we need to retry, we can return the file pointer to its initial position
      mypos = get_fileptr_offset(request_params)
      loop do
        # if we are inside a delay between retries: no requests this time!
        if error_count > @params[:http_connection_retry_count] &&
           error_time + @params[:http_connection_retry_delay] > Time.now
          # store the message (otherwise it will be lost after error_reset and
          # we will raise an exception with an empty text)
          banana_message_text = banana_message
          @logger.warn("#{err_header} re-raising same error: #{banana_message_text} " +
                      "-- error count: #{error_count}, error age: #{Time.now.to_i - error_time.to_i}")
          exception = get_param(:exception) || RuntimeError
          raise exception.new(banana_message_text)
        end

        # try to connect server(if connection does not exist) and get response data
        begin
          request_params[:protocol] ||= (request_params[:port] == 443 ? 'https' : 'http')

          request = request_params[:request]
          request['User-Agent'] = get_param(:user_agent) || ''

          # (re)open connection to server if none exists or params has changed
          unless @http          &&
                 @http.started? &&
                 @server   == request_params[:server] &&
                 @port     == request_params[:port]   &&
                 @protocol == request_params[:protocol]
            start(request_params)
          end

          # Detect if the body is a streamable object like a file or socket.  If so, stream that
          # bad boy.
          setup_streaming(request)
          response = @http.request(request, &block)

          error_reset
          eof_reset
          return response

        # We treat EOF errors and the timeout/network errors differently.  Both
        # are tracked in different statistics blocks.  Note below that EOF
        # errors will sleep for a certain (exponentially increasing) period.
        # Other errors don't sleep because there is already an inherent delay
        # in them; connect and read timeouts (for example) have already
        # 'slept'.  It is still not clear which way we should treat errors
        # like RST and resolution failures.  For now, there is no additional
        # delay for these errors although this may change in the future.

        # EOFError means the server closed the connection on us.
        rescue EOFError => e
          @logger.debug("#{err_header} server #{@server} closed connection")
          @http = nil

            # if we have waited long enough - raise an exception...
          if raise_on_eof_exception?
            exception = get_param(:exception) || RuntimeError
            @logger.warn("#{err_header} raising #{exception} due to permanent EOF being received from #{@server}, error age: #{Time.now.to_i - eof_time.to_i}")
            raise exception.new("Permanent EOF is being received from #{@server}.")
          else
              # ... else just sleep a bit before new retry
            sleep(add_eof)
            # We will be retrying the request, so reset the file pointer
            reset_fileptr_offset(request, mypos)
          end
        rescue Exception => e  # See comment at bottom for the list of errors seen...
          @http = nil
          # if ctrl+c is pressed - we have to reraise exception to terminate proggy
          if e.is_a?(Interrupt) && !( e.is_a?(Errno::ETIMEDOUT) || e.is_a?(Timeout::Error))
            @logger.debug( "#{err_header} request to server #{@server} interrupted by ctrl-c")
            raise
          elsif e.is_a?(ArgumentError) && e.message.include?('wrong number of arguments (5 for 4)')
            # seems our net_fix patch was overriden...
            exception = get_param(:exception) || RuntimeError
            raise exception.new('incompatible Net::HTTP monkey-patch')
          end
          # oops - we got a banana: log it
          error_add(e.message)
          @logger.warn("#{err_header} request failure count: #{error_count}, exception: #{e.inspect}")

          # We will be retrying the request, so reset the file pointer
          reset_fileptr_offset(request, mypos)

        end
      end
    end

    def finish(reason = '')
      if @http && @http.started?
        reason = ", reason: '#{reason}'" unless reason.blank?
        @logger.info("Closing #{@http.use_ssl? ? 'HTTPS' : 'HTTP'} connection to #{@http.address}:#{@http.port}#{reason}")
        @http.finish
      end
    end

  # Errors received during testing:
  #
  #  #<Timeout::Error: execution expired>
  #  #<Errno::ETIMEDOUT: Connection timed out - connect(2)>
  #  #<SocketError: getaddrinfo: Name or service not known>
  #  #<SocketError: getaddrinfo: Temporary failure in name resolution>
  #  #<EOFError: end of file reached>
  #  #<Errno::ECONNRESET: Connection reset by peer>
  #  #<OpenSSL::SSL::SSLError: SSL_write:: bad write retry>
  end

end

