module OpenidConnect
  class TokenEndpoint
    attr_accessor :app
    delegate :call, to: :app

    def initialize
      @app = Rack::OAuth2::Server::Token.new do |req, res|
        o_auth_app = retrieve_client(req)
        if app_valid?(o_auth_app, req)
          handle_flows(req, res)
        else
          req.invalid_client!
        end
      end
    end

    def handle_flows(req, res)
      case req.grant_type
      when :password
        handle_password_flow(req, res)
      when :refresh_token
        handle_refresh_flow(req, res)
      else
        req.unsupported_grant_type!
      end
    end

    def handle_password_flow(req, res)
      user = User.find_for_database_authentication(username: req.username)
      if user
        if user.valid_password?(req.password)
          res.access_token = token! user
        else
          req.invalid_grant!
        end
      else
        req.invalid_grant! # TODO: Change to user login: Perhaps redirect_to login_path?
      end
    end

    def handle_refresh_flow(req, res)
      user = OAuthApplication.find_by_client_id(req.client_id).user
      if RefreshToken.valid?(req.refresh_token)
        res.access_token = token! user
      else
        req.invalid_grant!
      end
    end

    def retrieve_client(req)
      OAuthApplication.find_by_client_id req.client_id
    end

    def app_valid?(o_auth_app, req)
      o_auth_app.client_secret == req.client_secret
    end

    def token!(user)
      user.tokens.create!.bearer_token
    end
  end
end
