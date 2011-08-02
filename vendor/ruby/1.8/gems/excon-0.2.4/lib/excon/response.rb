module Excon
  class Response

    def self.parse(socket, params = {}, &block)
      if params[:block]
        print "  \e[33m[WARN] params[:block] is deprecated, please pass the block to the request\e[0m"
        block = params[:block]
      end

      response = new

      response.status = socket.readline[9..11].to_i
      while true
        data = socket.readline.chop!
        unless data.empty?
          key, value = data.split(': ')
          response.headers[key] = value
        else
          break
        end
      end

      unless params[:method] == 'HEAD'
        if !block || (params[:expects] && ![*params[:expects]].include?(response.status))
          response.body = ''
          block = lambda { |chunk| response.body << chunk }
        end

        if response.headers['Transfer-Encoding'] && response.headers['Transfer-Encoding'].downcase == 'chunked'
          while true
            chunk_size = socket.readline.chop!.to_i(16)
            chunk = socket.read(chunk_size + 2).chop! # 2 == "/r/n".length
            if chunk_size > 0
              block.call(chunk)
            else
              break
            end
          end
        elsif response.headers['Connection'] && response.headers['Connection'].downcase == 'close'
          block.call(socket.read)
        elsif response.headers['Content-Length']
          remaining = response.headers['Content-Length'].to_i
          while remaining > 0
            block.call(socket.read([CHUNK_SIZE, remaining].min))
            remaining -= CHUNK_SIZE
          end
        end
      end

      response
    end

    attr_accessor :body, :headers, :status

    def initialize(attributes = {})
      @body    = attributes[:body] || ''
      @headers = attributes[:headers] || {}
      @status  = attributes[:status]
    end

  end
end
