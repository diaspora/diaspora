# frozen_string_literal: true

describe Api::OpenidConnect::DiscoveryController, type: :controller do
  describe "#configuration" do
    before do
      get :configuration
    end

    it "should have the issuer as the root url" do
      json_body = JSON.parse(response.body)
      expect(json_body["issuer"]).to eq(root_url)
    end

    it "should have the appropriate user info endpoint" do
      json_body = JSON.parse(response.body)
      expect(json_body["userinfo_endpoint"]).to eq(api_openid_connect_user_info_url)
    end
  end
end
