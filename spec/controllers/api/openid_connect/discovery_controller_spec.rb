describe Api::OpenidConnect::DiscoveryController, type: :controller do
  describe "#webfinger" do
    before do
      get :webfinger, resource: "http://example.com/bob"
    end

    it "should return a url to the openid-configuration" do
      json_body = JSON.parse(response.body)
      expect(json_body["links"].first["href"]).to eq(root_url)
    end

    it "should return the resource in the subject" do
      json_body = JSON.parse(response.body)
      expect(json_body["subject"]).to eq("http://example.com/bob")
    end
  end

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
