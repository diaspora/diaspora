module Api
  module OpenidConnect
    class IdTokensController < ApplicationController
      def jwks
        render json: JSON::JWK::Set.new(JSON::JWK.new(Api::OpenidConnect::IdTokenConfig.public_key, use: :sig)).as_json
      end
    end
  end
end
