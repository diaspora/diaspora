require "spec_helper"

describe OpenidConnect::ProtectedResourceEndpoint, type: :request do
  let!(:client) do
    OpenidConnect::OAuthApplication.create!(
      client_name: "Diaspora Test Client", redirect_uris: ["http://localhost:3000/"])
  end
  let(:auth_with_read) do
    auth = OpenidConnect::Authorization.find_or_create_by(o_auth_application: client, user: bob)
    auth.scopes << [OpenidConnect::Scope.find_or_create_by(name: "read")]
    auth
  end
  let!(:access_token_with_read) { auth_with_read.create_access_token.to_s }
  let(:auth_with_read_and_write) do
    auth = OpenidConnect::Authorization.find_or_create_by(o_auth_application: client, user: bob)
    auth.scopes << [OpenidConnect::Scope.find_or_create_by(name: "read"), OpenidConnect::Scope.find_or_create_by(name: "write")]
    auth
  end
  let!(:access_token_with_read_and_write) { auth_with_read_and_write.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(32).to_s }

  # TODO: Add tests for expired access tokens

  context "when read scope access token is provided for read required endpoint" do
    describe "user info endpoint" do
      before do
        get api_v0_user_path, access_token: access_token_with_read
      end

      it "shows the info" do
        json_body = JSON.parse(response.body)
        expect(json_body["username"]).to eq(bob.username)
        expect(json_body["email"]).to eq(bob.email)
      end

      it "includes private in the cache-control header" do
        expect(response.headers["Cache-Control"]).to include("private")
      end
    end
  end

  context "when no access token is provided" do
    it "should respond with a 401 Unauthorized response" do
      get api_v0_user_path
      expect(response.status).to be(401)
    end
    it "should have an auth-scheme value of Bearer" do
      get api_v0_user_path
      expect(response.headers["WWW-Authenticate"]).to include("Bearer")
    end
  end

  context "when an invalid access token is provided" do
    before do
      get api_v0_user_path, access_token: invalid_token
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
      get api_v0_user_path, access_token: access_token_with_read
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
