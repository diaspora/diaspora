require "spec_helper"

describe Api::OpenidConnect::ProtectedResourceEndpoint, type: :request do
  let(:auth_with_read) { FactoryGirl.create(:auth_with_read) }
  let!(:access_token_with_read) { auth_with_read.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(32).to_s }

  # TODO: Add tests for expired access tokens

  context "when valid access token is provided" do
    before do
      get api_openid_connect_user_info_path, access_token: access_token_with_read
    end

    it "includes private in the cache-control header" do
      expect(response.headers["Cache-Control"]).to include("private")
    end
  end

  context "when no access token is provided" do
    before do
      get api_openid_connect_user_info_path
    end

    it "should respond with a 401 Unauthorized response" do
      expect(response.status).to be(401)
    end
    it "should have an auth-scheme value of Bearer" do
      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
    end
  end

  context "when an invalid access token is provided" do
    before do
      get api_openid_connect_user_info_path, access_token: invalid_token
    end

    it "should respond with a 401 Unauthorized response" do
      expect(response.status).to be(401)
    end

    it "should have an auth-scheme value of Bearer" do
      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
    end

    it "should contain an invalid_token error" do
      expect(response.body).to include("invalid_token")
    end
  end

  context "when authorization has been destroyed" do
    before do
      auth_with_read.destroy
      get api_openid_connect_user_info_path, access_token: access_token_with_read
    end

    it "should respond with a 401 Unauthorized response" do
      expect(response.status).to be(401)
    end

    it "should have an auth-scheme value of Bearer" do
      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
    end

    it "should contain an invalid_token error" do
      expect(response.body).to include("invalid_token")
    end
  end
end
