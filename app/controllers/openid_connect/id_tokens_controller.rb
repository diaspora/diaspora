class OpenidConnect::IdTokensController < ApplicationController
    def jwks
      render json: JSON::JWK::Set.new(JSON::JWK.new(OpenidConnect::IdTokenConfig.public_key, use: :sig)).as_json
    end
end
