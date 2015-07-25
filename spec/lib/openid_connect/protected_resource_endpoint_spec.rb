require "spec_helper"

describe OpenidConnect::ProtectedResourceEndpoint, type: :request do
  describe "getting the user info" do
    let!(:client) do
      OpenidConnect::OAuthApplication.create!(
        client_name: "Diaspora Test Client", redirect_uris: ["http://localhost:3000/"])
    end
    let!(:auth) { OpenidConnect::Authorization.find_or_create_by(o_auth_application: client, user: bob) }
    let!(:access_token) { auth.create_access_token.to_s }
    let!(:invalid_token) { SecureRandom.hex(32).to_s }
    # TODO: Add tests for expired access tokens

    context "when access token is valid" do
      it "shows the user's username and email" do
        get "/api/v0/user/", access_token: access_token
        json_body = JSON.parse(response.body)
        expect(json_body["username"]).to eq(bob.username)
        expect(json_body["email"]).to eq(bob.email)
      end
      it "should include private in the cache-control header" do
        get "/api/v0/user/", access_token: access_token
        expect(response.headers["Cache-Control"]).to include("private")
      end
    end

    context "when no access token is provided" do
      it "should respond with a 401 Unauthorized response" do
        get "/api/v0/user/"
        expect(response.status).to be(401)
      end
      it "should have an auth-scheme value of Bearer" do
        get "/api/v0/user/"
        expect(response.headers["WWW-Authenticate"]).to include("Bearer")
      end
    end

    context "when an invalid access token is provided" do
      before do
        get "/api/v0/user/", access_token: invalid_token
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
        auth.destroy
        get "/api/v0/user/", access_token: access_token
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
end
