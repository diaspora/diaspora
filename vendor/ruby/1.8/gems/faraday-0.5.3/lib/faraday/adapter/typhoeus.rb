module Faraday
  class Adapter
    class Typhoeus < Faraday::Adapter
      self.supports_parallel_requests = true

      def self.setup_parallel_manager(options = {})
        options.empty? ? ::Typhoeus::Hydra.hydra : ::Typhoeus::Hydra.new(options)
      end

      begin
        require 'typhoeus'
      rescue LoadError, NameError => e
        self.load_error = e
      end

      def call(env)
        super

        req   = ::Typhoeus::Request.new env[:url].to_s,
          :method  => env[:method],
          :body    => env[:body],
          :headers => env[:request_headers],
          :disable_ssl_peer_verification => (env[:ssl][:verify] == false)

        env_req = env[:request]
        req.timeout = req.connect_timeout = (env_req[:timeout] * 1000) if env_req[:timeout]
        req.connect_timeout = (env_req[:open_timeout] * 1000)          if env_req[:open_timeout]

        req.on_complete do |resp|
          env.update \
            :status           => resp.code,
            :response_headers => parse_response_headers(resp.headers),
            :body             => resp.body
          env[:response].finish(env)
        end

        hydra = env[:parallel_manager] || self.class.setup_parallel_manager
        hydra.queue req

        if !env[:parallel_manager]
          hydra.run
        end

        @app.call env
      rescue Errno::ECONNREFUSED
        raise Error::ConnectionFailed.new(Errno::ECONNREFUSED)
      end

      def in_parallel(options = {})
        @hydra = ::Typhoeus::Hydra.new(options)
        yield
        @hydra.run
        @hydra = nil
      end

      def parse_response_headers(header_string)
        return {} unless header_string && !header_string.empty?
        Hash[*header_string.split(/\r\n/).
          tap    { |a|      a.shift           }. # drop the HTTP status line
          map    { |h|      h.split(/:\s+/,2) }. # split key and value
          reject { |(k, v)| k.nil?            }. # Ignore blank lines
          map    { |(k, v)| [k.downcase, v]   }.flatten]
      end

      # TODO: build in support for multipart streaming if typhoeus supports it.
      def create_multipart(env, params, boundary = nil)
        stream = super
        stream.read
      end
    end
  end
end
