module OpenidConnect
  class TokenEndpoint
    attr_accessor :app
    delegate :call, to: :app

    def initialize
      @app = Rack::OAuth2::Server::Token.new do |req, res|
        o_auth_app = retrieveClient(req)
        if isAppValid(o_auth_app, req)
          handleFlows(req, res)
        else
          req.invalid_client!
        end
      end
    end

    def handleFlows(req, res)
      case req.grant_type
        when :password
          handlePasswordFlow(req, res)
        else
          req.unsupported_grant_type!
      end
    end

    def handlePasswordFlow(req, res)
      user = User.find_for_database_authentication(username: req.username)
      if user
        if user.valid_password?(req.password)
          res.access_token = user.tokens.create!.bearer_token
        else
          req.invalid_grant!
        end
      else
        req.invalid_grant! # TODO: Change to user login: Perhaps redirect_to login_path?
      end
    end

    def retrieveClient(req)
      OAuthApplication.find_by_client_id req.client_id
    end

    def isAppValid(o_auth_app, req)
      o_auth_app.client_secret == req.client_secret
    end
  end
end
