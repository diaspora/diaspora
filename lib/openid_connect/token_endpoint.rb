module OpenidConnect
  class TokenEndpoint
    attr_accessor :app
    delegate :call, to: :app

    def initialize
      @app = Rack::OAuth2::Server::Token.new do |req, res|
        case req.grant_type
          when :password
            user = User.find_for_database_authentication(username: req.username)
            if user
              o_auth_app = retrieveOrCreateNewClientApplication(req, user)
              if o_auth_app && user.valid_password?(req.password)
                res.access_token = o_auth_app.tokens.create!.bearer_token
              else
                req.invalid_grant!
              end
            else
              req.invalid_grant! # TODO: Change to user login
            end
          else
            res.unsupported_grant_type!
        end
      end
    end

    def retrieveOrCreateNewClientApplication(req, user)
      retrieveClient(req, user) || createClient(req, user)
    end

    def retrieveClient(req, user)
      user.o_auth_applications.find_by_client_id req.client_id
    end

    def createClient(req, user)
      user.o_auth_applications.create!(client_id: req.client_id, client_secret: req.client_secret)
    end
  end
end
