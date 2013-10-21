
module Diaspora::Backbone
  module AuthHelpers

    module Helpers
      def authenticate!
        @current_user = request.env['warden'].authenticate
        redirect '/unauthenticated' unless @current_user
      end

      def authenticated?
        request.env['warden'].authenticated?
      end

      def current_user
        @current_user ||= request.env['warden'].user
      end
    end

    def self.registered(app)
      app.helpers AuthHelpers::Helpers

      if Rails.env.test?
        use Rack::Session::Cookie, key: Rails.application.config.session_options[:key],
                                   secret: Rails.application.config.secret_token

        app.use Warden::Manager do |m|
          m.default_scope = Devise.default_scope
          m.failure_app = Diaspora::Application
        end

        Warden::Manager.before_failure do |env, opts|
          env['REQUEST_METHOD'] = "GET"
        end
      end

      app.get "/unauthenticated" do
        request.env['warden'].custom_failure!
        halt_401_unauthorized
      end
    end
  end
end
