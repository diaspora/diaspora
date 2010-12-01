begin
  require 'net/https'
rescue LoadError
  puts "no such file to load -- net/https. Make sure openssl is installed if you want ssl support"
  require 'net/http'
end

module Faraday
  class Adapter
    class NetHttp < Faraday::Adapter
      def call(env)
        super

        is_ssl = env[:url].scheme == 'https'

        http = net_http_class(env).new(env[:url].host, env[:url].port || (is_ssl ? 443 : 80))
        if http.use_ssl = is_ssl
          ssl = env[:ssl]
          if ssl[:verify] == false
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          else
            http.verify_mode = ssl[:verify]
          end
          http.cert    = ssl[:client_cert] if ssl[:client_cert]
          http.key     = ssl[:client_key]  if ssl[:client_key]
          http.ca_file = ssl[:ca_file]     if ssl[:ca_file]
        end
        req = env[:request]
        http.read_timeout = net.open_timeout = req[:timeout] if req[:timeout]
        http.open_timeout = req[:open_timeout]               if req[:open_timeout]

        full_path = full_path_for(env[:url].path, env[:url].query, env[:url].fragment)
        http_req  = Net::HTTPGenericRequest.new(
          env[:method].to_s.upcase,    # request method
          (env[:body] ? true : false), # is there data
          true,                        # does net/http love you, true or false?
          full_path,                   # request uri path
          env[:request_headers])       # request headers

        if env[:body].respond_to?(:read)
          http_req.body_stream = env[:body]
          env[:body] = nil
        end

        http_resp = http.request http_req, env[:body]

        resp_headers = {}
        http_resp.each_header do |key, value|
          resp_headers[key] = value
        end

        env.update \
          :status           => http_resp.code.to_i,
          :response_headers => resp_headers,
          :body             => http_resp.body

        @app.call env
      rescue Errno::ECONNREFUSED
        raise Error::ConnectionFailed.new(Errno::ECONNREFUSED)
      end

      def net_http_class(env)
        if proxy = env[:request][:proxy]
          Net::HTTP::Proxy(proxy[:uri].host, proxy[:uri].port, proxy[:user], proxy[:password])
        else
          Net::HTTP
        end
      end
    end
  end
end
