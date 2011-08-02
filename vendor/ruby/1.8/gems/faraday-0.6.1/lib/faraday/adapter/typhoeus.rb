module Faraday
  class Adapter
    class Typhoeus < Faraday::Adapter
      self.supports_parallel_requests = true

      def self.setup_parallel_manager(options = {})
        options.empty? ? ::Typhoeus::Hydra.hydra : ::Typhoeus::Hydra.new(options)
      end

      dependency 'typhoeus'

      def call(env)
        super

        # TODO: support streaming requests
        env[:body] = env[:body].read if env[:body].respond_to? :read

        req = ::Typhoeus::Request.new env[:url].to_s,
          :method  => env[:method],
          :body    => env[:body],
          :headers => env[:request_headers],
          :disable_ssl_peer_verification => (env[:ssl] && !env[:ssl].fetch(:verify, true))

        env_req = env[:request]
        req.timeout = req.connect_timeout = (env_req[:timeout] * 1000) if env_req[:timeout]
        req.connect_timeout = (env_req[:open_timeout] * 1000)          if env_req[:open_timeout]

        is_parallel = !!env[:parallel_manager]
        req.on_complete do |resp|
          save_response(env, resp.code, resp.body) do |response_headers|
            response_headers.parse resp.headers
          end
          # in async mode, :response is initialized at this point
          env[:response].finish(env) if is_parallel
        end

        hydra = env[:parallel_manager] || self.class.setup_parallel_manager
        hydra.queue req
        hydra.run unless is_parallel

        @app.call env
      rescue Errno::ECONNREFUSED
        raise Error::ConnectionFailed, $!
      end
    end
  end
end
