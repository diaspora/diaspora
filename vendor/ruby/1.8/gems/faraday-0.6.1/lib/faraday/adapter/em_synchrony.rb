module Faraday
  class Adapter
    class EMSynchrony < Faraday::Adapter
      dependency do
        require 'em-synchrony/em-http'
        require 'fiber'
      end

      def call(env)
        super
        request = EventMachine::HttpRequest.new(URI::parse(env[:url].to_s))
        options = {:head => env[:request_headers]}
        options[:ssl] = env[:ssl] if env[:ssl]

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
              :port => uri.inferred_port
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

        save_response(env, client.response_header.status, client.response) do |response_headers|
          client.response_header.each do |name, value|
            response_headers[name.to_sym] = value
          end
        end

        @app.call env
      rescue Errno::ECONNREFUSED
        raise Error::ConnectionFailed, $!
      end
    end
  end
end
