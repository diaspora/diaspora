module Faraday
  class Adapter
    class Patron < Faraday::Adapter
      begin
        require 'patron'
      rescue LoadError, NameError => e
        self.load_error = e
      end

      def call(env)
        super

        sess = ::Patron::Session.new
        args = [env[:method], env[:url].to_s, env[:request_headers]]
        if Faraday::Connection::METHODS_WITH_BODIES.include?(env[:method])
          args.insert(2, env[:body].to_s)
        end
        resp = sess.send *args

        env.update \
          :status           => resp.status,
          :response_headers => resp.headers.
            inject({}) { |memo, (k, v)| memo.update(k.downcase => v) },
          :body             => resp.body
        env[:response].finish(env)

        @app.call env
      rescue Errno::ECONNREFUSED
        raise Error::ConnectionFailed.new(Errno::ECONNREFUSED)
      end

      # TODO: build in support for multipart streaming if patron supports it.
      def create_multipart(env, params, boundary = nil)
        stream = super
        stream.read
      end
    end
  end
end
