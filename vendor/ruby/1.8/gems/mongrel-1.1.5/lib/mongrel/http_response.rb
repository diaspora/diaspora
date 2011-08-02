module Mongrel
  # Writes and controls your response to the client using the HTTP/1.1 specification.
  # You use it by simply doing:
  #
  #  response.start(200) do |head,out|
  #    head['Content-Type'] = 'text/plain'
  #    out.write("hello\n")
  #  end
  #
  # The parameter to start is the response code--which Mongrel will translate for you
  # based on HTTP_STATUS_CODES.  The head parameter is how you write custom headers.
  # The out parameter is where you write your body.  The default status code for 
  # HttpResponse.start is 200 so the above example is redundant.
  # 
  # As you can see, it's just like using a Hash and as you do this it writes the proper
  # header to the output on the fly.  You can even intermix specifying headers and 
  # writing content.  The HttpResponse class with write the things in the proper order
  # once the HttpResponse.block is ended.
  #
  # You may also work the HttpResponse object directly using the various attributes available
  # for the raw socket, body, header, and status codes.  If you do this you're on your own.
  # A design decision was made to force the client to not pipeline requests.  HTTP/1.1 
  # pipelining really kills the performance due to how it has to be handled and how 
  # unclear the standard is.  To fix this the HttpResponse gives a "Connection: close"
  # header which forces the client to close right away.  The bonus for this is that it
  # gives a pretty nice speed boost to most clients since they can close their connection
  # immediately.
  #
  # One additional caveat is that you don't have to specify the Content-length header
  # as the HttpResponse will write this for you based on the out length.
  class HttpResponse
    attr_reader :socket
    attr_reader :body
    attr_writer :body
    attr_reader :header
    attr_reader :status
    attr_writer :status
    attr_reader :body_sent
    attr_reader :header_sent
    attr_reader :status_sent

    def initialize(socket)
      @socket = socket
      @body = StringIO.new
      @status = 404
      @reason = nil
      @header = HeaderOut.new(StringIO.new)
      @header[Const::DATE] = Time.now.httpdate
      @body_sent = false
      @header_sent = false
      @status_sent = false
    end

    # Receives a block passing it the header and body for you to work with.
    # When the block is finished it writes everything you've done to 
    # the socket in the proper order.  This lets you intermix header and
    # body content as needed.  Handlers are able to modify pretty much
    # any part of the request in the chain, and can stop further processing
    # by simple passing "finalize=true" to the start method.  By default
    # all handlers run and then mongrel finalizes the request when they're
    # all done.
    def start(status=200, finalize=false, reason=nil)
      @status = status.to_i
      @reason = reason
      yield @header, @body
      finished if finalize
    end

    # Primarily used in exception handling to reset the response output in order to write
    # an alternative response.  It will abort with an exception if you have already
    # sent the header or the body.  This is pretty catastrophic actually.
    def reset
      if @body_sent
        raise "You have already sent the request body."
      elsif @header_sent
        raise "You have already sent the request headers."
      else
        @header.out.truncate(0)
        @body.close
        @body = StringIO.new
      end
    end

    def send_status(content_length=@body.length)
      if not @status_sent
        @header['Content-Length'] = content_length if content_length and @status != 304
        write(Const::STATUS_FORMAT % [@status, @reason || HTTP_STATUS_CODES[@status]])
        @status_sent = true
      end
    end

    def send_header
      if not @header_sent
        @header.out.rewind
        write(@header.out.read + Const::LINE_END)
        @header_sent = true
      end
    end

    def send_body
      if not @body_sent
        @body.rewind
        write(@body.read)
        @body_sent = true
      end
    end 

    # Appends the contents of +path+ to the response stream.  The file is opened for binary
    # reading and written in chunks to the socket.
    #
    # Sendfile API support has been removed in 0.3.13.4 due to stability problems.
    def send_file(path, small_file = false)
      if small_file
        File.open(path, "rb") {|f| @socket << f.read }
      else
        File.open(path, "rb") do |f|
          while chunk = f.read(Const::CHUNK_SIZE) and chunk.length > 0
            begin
              write(chunk)
            rescue Object => exc
              break
            end
          end
        end
      end
      @body_sent = true
    end

    def socket_error(details)
      # ignore these since it means the client closed off early
      @socket.close rescue nil
      done = true
      raise details
    end

    def write(data)
      @socket.write(data)
    rescue => details
      socket_error(details)
    end

    # This takes whatever has been done to header and body and then writes it in the
    # proper format to make an HTTP/1.1 response.
    def finished
      send_status
      send_header
      send_body
    end

    # Used during error conditions to mark the response as "done" so there isn't any more processing
    # sent to the client.
    def done=(val)
      @status_sent = true
      @header_sent = true
      @body_sent = true
    end

    def done
      (@status_sent and @header_sent and @body_sent)
    end

  end
end