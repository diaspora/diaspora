class TokenEndpoint
  attr_accessor :app
  delegate :call, to: :app

  def initialize
    @app = Rack::OAuth2::Server::Token.new do |req, res|
      case req.grant_type
        when :password
          # If the grant type is password, the application does not have to be known
          # If it does not exist, insert into DB
          user = User.find_for_database_authentication(username: req.username)
          o_auth_app = OAuthApplication.find_by_client_id req.client_id
          o_auth_app ||= OAuthApplication.create!(client_id: req.client_id, client_secret: req.client_secret)
          if user.valid_password? req.password
            res.access_token = o_auth_app.tokens.create!.bearer_token
          end
        else
          req.unsupported_grant_type!
      end
    end
  end
end
