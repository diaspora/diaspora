# frozen_string_literal: true

module Api
  module OpenidConnect
    class TokenEndpointController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        req = Rack::Request.new(request.env)
        if req["client_assertion_type"] == "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
          handle_jwt_bearer(req)
        end
        self.status, headers, self.response_body = Api::OpenidConnect::TokenEndpoint.new.call(request.env)
        headers.each {|name, value| response.headers[name] = value }
        nil
      end

      private

      def handle_jwt_bearer(req)
        jwt_string = req["client_assertion"]
        jwt = JSON::JWT.decode jwt_string, :skip_verification
        o_auth_app = Api::OpenidConnect::OAuthApplication.find_by(client_id: jwt["iss"])
        raise Rack::OAuth2::Server::Authorize::BadRequest(:invalid_request) unless o_auth_app
        public_key = fetch_public_key(o_auth_app, jwt)
        JSON::JWT.decode(jwt_string, JSON::JWK.new(public_key).to_key)
        req.update_param("client_id", o_auth_app.client_id)
        req.update_param("client_secret", o_auth_app.client_secret)
      end

      def fetch_public_key(o_auth_app, jwt)
        public_key = fetch_public_key_from_json(o_auth_app.jwks, jwt)
        if public_key.empty? && o_auth_app.jwks_uri
          response = Faraday.get(o_auth_app.jwks_uri)
          public_key = fetch_public_key_from_json(response.body, jwt)
        end
        raise Rack::OAuth2::Server::Authorize::BadRequest(:unauthorized_client) if public_key.empty?
        public_key
      end

      def fetch_public_key_from_json(string, jwt)
        json = JSON.parse(string)
        keys = json["keys"]
        public_key = get_key_from_kid(keys, jwt.header["kid"])
        public_key
      end

      def get_key_from_kid(keys, kid)
        keys.each do |key|
          return key if key.has_value?(kid)
        end
      end

      rescue_from Rack::OAuth2::Server::Authorize::BadRequest,
                  JSON::JWT::InvalidFormat, JSON::JWK::UnknownAlgorithm do |e|
        logger.info e.backtrace[0, 10].join("\n")
        render json: {error: :invalid_request, error_description: e.message, status: 400}
      end
      rescue_from JSON::JWT::VerificationFailed do |e|
        logger.info e.backtrace[0, 10].join("\n")
        render json: {error: :invalid_grant, error_description: e.message, status: 400}
      end
    end
  end
end
