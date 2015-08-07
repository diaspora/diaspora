module Api
  module OpenidConnect
    class IdTokensController < ApplicationController
      def jwks
        render json: JSON::JWK::Set.new(build_jwk).as_json
      end

      private

      def build_jwk
        JSON::JWK.new(Api::OpenidConnect::IdTokenConfig::PUBLIC_KEY, use: :sig)
      end
    end
  end
end
