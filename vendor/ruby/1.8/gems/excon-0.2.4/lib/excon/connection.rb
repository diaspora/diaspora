module Excon
  class Connection

    def initialize(url, params = {})
      uri = URI.parse(url)
      @connection = {
        :headers  => {},
        :host     => uri.host,
        :path     => uri.path,
        :port     => uri.port,
        :query    => uri.query,
        :scheme   => uri.scheme
      }.merge!(params)
    end

    def request(params, &block)
      begin
        params[:path] ||= @connection[:path]
        unless params[:path][0..0] == '/'
          params[:path] = "/#{params[:path]}"
        end
        request = "#{params[:method].upcase} #{params[:path]}?"
        for key, values in (params[:query] || @connection[:query] || {})
          for value in [*values]
            request << "#{key}#{value && "=#{CGI.escape(value.to_s)}"}&"
          end
        end
        request.chop!
        request << " HTTP/1.1\r\n"
        params[:headers] ||= @connection[:headers]
        params[:headers]['Host'] ||= params[:host] || @connection[:host]
        params[:body] ||= @connection[:body]
        params[:headers]['Content-Length'] = case params[:body]
        when File
          params[:body].binmode
          File.size(params[:body].path)
        when String
          if params[:body].respond_to?(:force_encoding)
            params[:body].force_encoding('BINARY')
          end
          params[:body].length
        else
          0
        end
        for key, value in params[:headers]
          request << "#{key}: #{value}\r\n"
        end
        request << "\r\n"
        socket.write(request)

        if params[:body]
          if params[:body].is_a?(String)
            socket.write(params[:body])
          else
            while chunk = params[:body].read(CHUNK_SIZE)
              socket.write(chunk)
            end
          end
        end

        response = Excon::Response.parse(socket, params, &block)
        if response.headers['Connection'] == 'close'
          reset
        end
        response
      rescue => socket_error
        reset
        raise(socket_error)
      end

      if params[:expects] && ![*params[:expects]].include?(response.status)
        reset
        raise(Excon::Errors.status_error(params, response))
      else
        response
      end

    rescue => request_error
      if params[:idempotent] &&
          (!request_error.is_a?(Excon::Errors::Error) || response.status != 404)
        retries_remaining ||= 4
        retries_remaining -= 1
        if retries_remaining > 0
          retry
        else
          raise(request_error)
        end
      else
        raise(request_error)
      end
    end

    def reset
      (old_socket = sockets.delete(socket_key)) && old_socket.close
    end

    private

    def connect
      new_socket = TCPSocket.open(@connection[:host], @connection[:port])

      if @connection[:scheme] == 'https'
        @ssl_context = OpenSSL::SSL::SSLContext.new
        @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
        new_socket = OpenSSL::SSL::SSLSocket.new(new_socket, @ssl_context)
        new_socket.sync_close = true
        new_socket.connect
      end

      new_socket
    end

    def closed?
      sockets[socket_key] && sockets[socket_key].closed?
    end

    def socket
      if closed?
        reset
      end
      sockets[socket_key] ||= connect
    end

    def sockets
      Thread.current[:_excon_sockets] ||= {}
    end

    def socket_key
      "#{@connection[:host]}:#{@connection[:port]}"
    end
  end
end
