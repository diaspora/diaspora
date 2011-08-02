#
# Copyright (c) 2008 RightScale Inc
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
#

# Net::HTTP and Net::HTTPGenericRequest fixes to support 100-continue on 
# POST and PUT. The request must have 'expect' field set to '100-continue'.


module Net
  
  class BufferedIO #:nodoc:
    # Monkey-patch Net::BufferedIO to read > 1024 bytes from the socket at a time

    # Default size (in bytes) of the max read from a socket into the user space read buffers for socket IO
    DEFAULT_SOCKET_READ_SIZE = 16*1024

    @@socket_read_size = DEFAULT_SOCKET_READ_SIZE

    def self.socket_read_size=(readsize)
      if(readsize <= 0)
        return
      end
      @@socket_read_size = readsize
    end

    def self.socket_read_size?()
      @@socket_read_size
    end

    def rbuf_fill
      timeout(@read_timeout) {
        @rbuf << @io.sysread(@@socket_read_size)
      }
    end
  end


  #-- Net::HTTPGenericRequest --

  class HTTPGenericRequest
    # Monkey-patch Net::HTTPGenericRequest to read > 1024 bytes from the local data
    # source at a time (used in streaming PUTs)

    # Default size (in bytes) of the max read from a local source (File, String,
    # etc.) to the user space write buffers for socket IO.
    DEFAULT_LOCAL_READ_SIZE = 16*1024

    @@local_read_size = DEFAULT_LOCAL_READ_SIZE

    def self.local_read_size=(readsize)
      if(readsize <= 0)
        return
      end
      @@local_read_size = readsize
    end

    def self.local_read_size?()
      @@local_read_size
    end

    def exec(sock, ver, path, send_only=nil)   #:nodoc: internal use only
      if @body
        send_request_with_body sock, ver, path, @body, send_only
      elsif @body_stream
        send_request_with_body_stream sock, ver, path, @body_stream, send_only
      else
        write_header(sock, ver, path)
      end
    end

    private

    def send_request_with_body(sock, ver, path, body, send_only=nil)
      self.content_length = body.length
      delete 'Transfer-Encoding'
      supply_default_content_type
      write_header(sock, ver, path) unless send_only == :body
      sock.write(body)              unless send_only == :header
    end

    def send_request_with_body_stream(sock, ver, path, f, send_only=nil)
      unless content_length() or chunked?
        raise ArgumentError,
            "Content-Length not given and Transfer-Encoding is not `chunked'"
      end
      supply_default_content_type
      write_header(sock, ver, path) unless send_only == :body
      unless send_only == :header
        if chunked?
          while s = f.read(@@local_read_size)
            sock.write(sprintf("%x\r\n", s.length) << s << "\r\n")
          end
          sock.write "0\r\n\r\n"
        else
          while s = f.read(@@local_read_size)
            sock.write s
          end
        end
      end
    end    
  end


  #-- Net::HTTP --
  
  class HTTP
    def request(req, body = nil, &block)  # :yield: +response+
      unless started?
        start {
          req['connection'] ||= 'close'
          return request(req, body, &block)
        }
      end
      if proxy_user()
        unless use_ssl?
          req.proxy_basic_auth proxy_user(), proxy_pass()
        end
      end
      # set body
      req.set_body_internal body
      begin_transport req
        # if we expect 100-continue then send a header first
        send_only = ((req.is_a?(Post)||req.is_a?(Put)) && (req['expect']=='100-continue')) ? :header : nil
        req.exec @socket, @curr_http_version, edit_path(req.path), send_only
        begin
          res = HTTPResponse.read_new(@socket)
          # if we expected 100-continue then send a body
          if res.is_a?(HTTPContinue) && send_only && req['content-length'].to_i > 0
            req.exec @socket, @curr_http_version, edit_path(req.path), :body
          end
        end while res.kind_of?(HTTPContinue)
        res.reading_body(@socket, req.response_body_permitted?) {
          yield res if block_given?
        }
      end_transport req, res
      res
    end
  end

end
