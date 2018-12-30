# frozen_string_literal: true

describe Api::OpenidConnect::IdToken, type: :model do
  describe "#to_jwt" do
    let(:auth) { FactoryGirl.create(:auth_with_default_scopes) }
    let(:id_token) { Api::OpenidConnect::IdToken.new(auth, "nonce") }

    describe "decoded data" do
      let(:decoded_hash) {
        JSON::JWT.decode(id_token.to_jwt, Api::OpenidConnect::IdTokenConfig::PRIVATE_KEY)
      }
      let(:webfinger) {
        DiasporaFederation.callbacks.trigger(:fetch_person_for_webfinger, alice.diaspora_handle).to_json
      }

      it "issuer value must much the one we provided in OpenID discovery routine" do
        openid_issuer = webfinger[:links].find {|l| l[:rel] == OpenIDConnect::Discovery::Provider::Issuer::REL_VALUE }
        expect(decoded_hash["iss"]).to eq(openid_issuer[:href])
      end
    end
  end
end
