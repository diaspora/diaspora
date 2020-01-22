# frozen_string_literal: true

describe Api::OpenidConnect::ProtectedResourceEndpoint, type: :request do
  let(:auth_with_read) { FactoryGirl.create(:auth_with_read_scopes) }
  let!(:access_token_with_read) { auth_with_read.create_access_token.to_s }
  let!(:expired_access_token) do
    access_token = auth_with_read.o_auth_access_tokens.create!
    access_token.expires_at = Time.zone.now - 100
    access_token.save
    access_token.bearer_token.to_s
  end
  let(:invalid_token) { SecureRandom.hex(32).to_s }

  context "when valid access token is provided" do
    before do
      get api_openid_connect_user_info_path, params: {access_token: access_token_with_read}
    end

    it "includes private in the cache-control header" do
      expect(response.headers["Cache-Control"]).to include("private")
    end
  end

  context "when access token is expired" do
    before do
      get api_openid_connect_user_info_path, params: {access_token: expired_access_token}
    end

    it "should respond with a 401 Unauthorized response" do
      expect(response.status).to be(401)
    end
    it "should have an auth-scheme value of Bearer" do
      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
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
      get api_openid_connect_user_info_path, params: {access_token: invalid_token}
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
      get api_openid_connect_user_info_path, params: {access_token: access_token_with_read}
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
