require "spec_helper"

describe Api::OpenidConnect::DiscoveryController, type: :controller do
  describe "#webfinger" do
    before do
      get :webfinger, resource: "http://test.host/bob"
    end

    it "should return a url to the openid-configuration" do
      json_body = JSON.parse(response.body)
      expect(json_body["links"].first["href"]).to eq("http://test.host/api/openid_connect")
    end

    it "should return the resource in the subject" do
      json_body = JSON.parse(response.body)
      expect(json_body["subject"]).to eq("http://test.host/bob")
    end
  end

  describe "#configuration" do
    it "should have the issuer as the root url" do
      get :configuration
      json_body = JSON.parse(response.body)
      expect(json_body["issuer"]).to eq("http://test.host/")
    end
  end
end
