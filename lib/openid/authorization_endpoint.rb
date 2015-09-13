module Openid
  class AuthorizationEndpoint
    attr_accessor :app, :account, :client, :redirect_uri, :response_type, :scopes, :_request_, :request_uri, :request_object
    delegate :call, to: :app

    def initialize(allow_approval = false, approved = false)
      @app = Rack::OAuth2::Server::Authorize.new do |req, res|
        req.unsupported_response_type! # TODO: not supported yet
      end
    end
  end
end
