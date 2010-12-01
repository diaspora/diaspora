require 'em-synchrony/em-http'
require 'fiber'

module Faraday
  class Adapter
    class EMSynchrony < Faraday::Adapter

      class Header
        include Net::HTTPHeader
        def initialize response
          @header = {}
          response.response_header.each do |key, value|
            case key
            when "CONTENT_TYPE"; self.content_type = value
            when "CONTENT_LENGTH"; self.content_length = value
            else; self[key] = value
            end
          end
        end
      end

      def call(env)
        process_body_for_request(env)
        
        request = EventMachine::HttpRequest.new(URI::parse(env[:url].to_s))
        
        options = {:head => env[:request_headers]}

        if env[:body]
          if env[:body].respond_to? :read
            options[:body] = env[:body].read
          else
            options[:body] = env[:body]
          end
        end

        if req = env[:request]
          if proxy = req[:proxy]
            uri = Addressable::URI.parse(proxy[:uri])
            options[:proxy] = {
              :host => uri.host,
              :port => uri.port
            }
            if proxy[:username] && proxy[:password]
              options[:proxy][:authorization] = [proxy[:username], proxy[:password]]
            end
          end

          # only one timeout currently supported by em http request
          if req[:timeout] or req[:open_timeout]
            options[:timeout] = [req[:timeout] || 0, req[:open_timeout] || 0].max
          end
        end

        client = nil
        block = lambda { request.send env[:method].to_s.downcase.to_sym, options }
        if !EM.reactor_running?
          EM.run {
            Fiber.new do
              client = block.call
              EM.stop
            end.resume
          }
        else
          client = block.call
        end

        env.update(:status           => client.response_header.http_status.to_i,
                   :response_headers => Header.new(client),
                   :body             => client.response)

        @app.call env
      rescue Errno::ECONNREFUSED
        raise Error::ConnectionFailed, "connection refused"
      end
    end
  end
end
