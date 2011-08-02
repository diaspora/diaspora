begin
  require 'net/https'
rescue LoadError
  warn "Warning: no such file to load -- net/https. Make sure openssl is installed if you want ssl support"
  require 'net/http'
end

module Faraday
  class Adapter
    class NetHttp < Faraday::Adapter
      def call(env)
        super
        url = env[:url]
        req = env[:request]

        http = net_http_class(env).new(url.host, url.inferred_port)

        if http.use_ssl = (url.scheme == 'https' && env[:ssl])
          ssl = env[:ssl]
          http.verify_mode = ssl[:verify_mode] || ssl.fetch(:verify, true) ?
                               OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
          http.cert        = ssl[:client_cert] if ssl[:client_cert]
          http.key         = ssl[:client_key]  if ssl[:client_key]
          http.ca_file     = ssl[:ca_file]     if ssl[:ca_file]
          http.ca_path     = ssl[:ca_path]     if ssl[:ca_path]
          http.cert_store  = ssl[:cert_store]  if ssl[:cert_store]
        end

        http.read_timeout = http.open_timeout = req[:timeout] if req[:timeout]
        http.open_timeout = req[:open_timeout]                if req[:open_timeout]

        if :get != env[:method]
          http_request = Net::HTTPGenericRequest.new \
            env[:method].to_s.upcase,    # request method
            !!env[:body],                # is there data
            true,                        # does net/http love you, true or false?
            url.request_uri,             # request uri path
            env[:request_headers]        # request headers

          if env[:body].respond_to?(:read)
            http_request.body_stream = env[:body]
            env[:body] = nil
          end
        end

        begin
          http_response = if :get == env[:method]
            # prefer `get` to `request` because the former handles gzip (ruby 1.9)
            http.get url.request_uri, env[:request_headers]
          else
            http.request http_request, env[:body]
          end
        rescue Errno::ECONNREFUSED
          raise Error::ConnectionFailed, $!
        end

        save_response(env, http_response.code.to_i, http_response.body) do |response_headers|
          http_response.each_header do |key, value|
            response_headers[key] = value
          end
        end

        @app.call env
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
