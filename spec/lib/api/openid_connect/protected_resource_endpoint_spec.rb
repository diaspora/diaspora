require "spec_helper"

describe Api::OpenidConnect::ProtectedResourceEndpoint, type: :request do
  # TODO: Replace with factory
  let!(:client) do
    Api::OpenidConnect::OAuthApplication.create!(
      client_name: "Diaspora Test Client", redirect_uris: ["http://localhost:3000/"])
  end
  let(:auth_with_read) do
    auth = Api::OpenidConnect::Authorization.create!(o_auth_application: client, user: alice)
    auth.scopes << [Api::OpenidConnect::Scope.find_by!(name: "openid"),
                    Api::OpenidConnect::Scope.find_by!(name: "read")]
    auth
  end
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
