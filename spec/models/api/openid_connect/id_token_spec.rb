describe Api::OpenidConnect::IdToken, type: :model do
  describe "#to_jwt" do
    let(:auth) { FactoryGirl.create(:auth_with_read) }
    let(:id_token) { Api::OpenidConnect::IdToken.new(auth, "nonce") }

    describe "decoded data" do
      let(:decoded_hash) {
        JSON::JWT.decode(id_token.to_jwt, Api::OpenidConnect::IdTokenConfig::PRIVATE_KEY)
      }
      let(:discovery_controller) {
        Api::OpenidConnect::DiscoveryController.new.tap {|controller|
          controller.request = ActionController::TestRequest.new
          controller.request.host = AppConfig.pod_uri.authority
          controller.response = ActionController::TestResponse.new
        }
      }
      let(:openid_webfinger) {
        JSON.parse(discovery_controller.webfinger[0])
      }

      it "issuer value must much the one we provided in OpenID discovery routine" do
        expect(decoded_hash["iss"]).to eq(openid_webfinger["links"][0]["href"])
      end
    end
  end
end
