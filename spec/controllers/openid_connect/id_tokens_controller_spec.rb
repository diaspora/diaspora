require "spec_helper"

describe OpenidConnect::IdTokensController, type: :controller do
  describe "#jwks" do
    before do
      get :jwks
    end

    it "should contain a public key that matches the internal private key" do
      json = JSON.parse(response.body).with_indifferent_access
      jwks = JSON::JWK::Set.new json[:keys]
      public_keys = jwks.map do |jwk|
        JSON::JWK.decode jwk
      end
      public_key = public_keys.first
      expect(OpenidConnect::IdTokenConfig.private_key.public_key.to_s).to eq(public_key.to_s)
    end
  end
end
