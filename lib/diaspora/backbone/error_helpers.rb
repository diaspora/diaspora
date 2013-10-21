
module Diaspora::Backbone
  module ErrorHelpers
    module Helpers
      def error_msg(msg, note=nil)
        data = { message: msg }
        data[:notice] = note unless note.nil?
        json(data)
      end

      def halt_400_bad_request(msg=nil)
        halt 400, error_msg("Bad request!", msg)
      end

      def halt_401_unauthorized
        halt 401, error_msg("Unauthorized!")
      end

      def halt_404_not_found
        halt 404, error_msg("Not found!")
      end

      def halt_405_not_allowed
        halt 405, error_msg("Not allowed!")
      end

      def halt_500_server_error
        halt 500, error_msg("Internal server error!")
      end
    end

    def self.registered(app)
      app.helpers ErrorHelpers::Helpers

      app.error do
        # TODO add some sort of logging facility here...
        puts env['sinatra.error']
        puts env['sinatra.error'].backtrace
        halt_500_server_error
      end
    end
  end
end
