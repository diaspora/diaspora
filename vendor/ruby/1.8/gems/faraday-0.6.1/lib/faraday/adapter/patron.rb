module Faraday
  class Adapter
    class Patron < Faraday::Adapter
      dependency 'patron'

      def call(env)
        super

        # TODO: support streaming requests
        env[:body] = env[:body].read if env[:body].respond_to? :read

        session = ::Patron::Session.new

        response = begin
          if Connection::METHODS_WITH_BODIES.include? env[:method]
            session.send(env[:method], env[:url].to_s, env[:body].to_s, env[:request_headers])
          else
            session.send(env[:method], env[:url].to_s, env[:request_headers])
          end
        rescue Errno::ECONNREFUSED
          raise Error::ConnectionFailed, $!
        end

        save_response(env, response.status, response.body, response.headers)

        @app.call env
      end
    end
  end
end
