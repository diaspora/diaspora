module Openid
  class TokenEndpoint
    attr_accessor :app
    delegate :call, to: :app

    def initialize
      @app = Rack::OAuth2::Server::Token.new do |req, res|
        case req.grant_type
          when :password
            o_auth_app = retrieveOrCreateNewClientApplication(req)
            user = User.find_for_database_authentication(username: req.username)
            if o_auth_app && user && user.valid_password?(req.password)
              res.access_token = o_auth_app.tokens.create!.bearer_token
            else
              req.invalid_grant!
            end
          else
            res.unsupported_grant_type!
        end
      end
    end

    def retrieveOrCreateNewClientApplication(req)
      retrieveClient(req) || createClient(req)
    end

    def retrieveClient(req)
      OAuthApplication.find_by_client_id req.client_id
    end

    def createClient(req)
      OAuthApplication.create!(client_id: req.client_id, client_secret: req.client_secret)
    end
  end
end
