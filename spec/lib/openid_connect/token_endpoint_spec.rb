require "spec_helper"

describe OpenidConnect::TokenEndpoint, type: :request do
  let!(:client) do
    OpenidConnect::OAuthApplication.create!(
      redirect_uris: ["http://localhost"], client_name: "diaspora client")
  end
  let!(:auth) { OpenidConnect::Authorization.find_or_create_by(o_auth_application: client, user: bob) }

  describe "the password grant type" do
    context "when the username field is missing" do
      it "should return an invalid request error" do
        post "/openid_connect/access_tokens", grant_type: "password", password: "bluepin7",
             client_id: client.client_id, client_secret: client.client_secret
        expect(response.body).to include "'username' required"
      end
    end

    context "when the password field is missing" do
      it "should return an invalid request error" do
        post "/openid_connect/access_tokens", grant_type: "password", username: "bob",
             client_id: client.client_id, client_secret: client.client_secret
        expect(response.body).to include "'password' required"
      end
    end

    context "when the username does not match an existing user" do
      it "should return an invalid request error" do
        post "/openid_connect/access_tokens", grant_type: "password", username: "randomnoexist",
             password: "bluepin7", client_id: client.client_id, client_secret: client.client_secret
        expect(response.body).to include "invalid_grant"
      end
    end

    context "when the password is invalid" do
      it "should return an invalid request error" do
        post "/openid_connect/access_tokens", grant_type: "password", username: "bob",
             password: "wrongpassword", client_id: client.client_id, client_secret: client.client_secret
        expect(response.body).to include "invalid_grant"
      end
    end

    context "when the client_secret doesn't match" do
      it "should return an invalid client error" do
        post "/openid_connect/access_tokens", grant_type: "password", username: "bob",
             password: "bluepin7", client_id: client.client_id, client_secret: "client.client_secret"
        expect(response.body).to include "invalid_client"
      end
    end

    context "when the request is valid" do
      it "should return an access token" do
        post "/openid_connect/access_tokens", grant_type: "password", username: "bob",
             password: "bluepin7", client_id: client.client_id, client_secret: client.client_secret
        json = JSON.parse(response.body)
        expect(json.keys).to include "expires_in"
        expect(json["access_token"].length).to eq(64)
        expect(json["token_type"]).to eq("bearer")
      end
    end

    context "when there are duplicate fields" do
      it "should return an invalid request error" do
        post "/openid_connect/access_tokens", grant_type: "password", username: "bob", password: "bluepin7",
             username: "bob", password: "bluepin6", client_id: client.client_id, client_secret: client.client_secret
        expect(response.body).to include "invalid_grant"
      end
    end

    context "when the client is unregistered" do
      it "should return an error" do
        post "/openid_connect/access_tokens", grant_type: "password", username: "bob",
             password: "bluepin7", client_id: SecureRandom.hex(16).to_s, client_secret: client.client_secret
        expect(response.body).to include "invalid_client"
      end
    end
    # TODO: Support a way to prevent brute force attacks using rate-limitation
    # as specified by RFC 6749 4.3.2 Access Token Request
  end

  describe "an unsupported grant type" do
    it "should return an unsupported grant type error" do
      post "/openid_connect/access_tokens", grant_type: "noexistgrant", username: "bob",
           password: "bluepin7", client_id: client.client_id, client_secret: client.client_secret
      expect(response.body).to include "unsupported_grant_type"
    end
  end

  describe "the refresh token flow" do
    context "when the refresh token is valid" do
      it "should return an access token" do
        post "/openid_connect/access_tokens", grant_type: "refresh_token",
             client_id: client.client_id, client_secret: client.client_secret, refresh_token: auth.refresh_token
        json = JSON.parse(response.body)
        expect(response.body).to include "expires_in"
        expect(json["access_token"].length).to eq(64)
        expect(json["token_type"]).to eq("bearer")
      end
    end

    context "when the refresh token is not valid" do
      it "should return an invalid grant error" do
        post "/openid_connect/access_tokens", grant_type: "refresh_token",
             client_id: client.client_id, client_secret: client.client_secret, refresh_token: " "
        expect(response.body).to include "invalid_grant"
      end
    end

    context "when the client is unregistered" do
      it "should return an error" do
        post "/openid_connect/access_tokens", grant_type: "refresh_token", refresh_token: auth.refresh_token,
             client_id: SecureRandom.hex(16).to_s, client_secret: client.client_secret
        expect(response.body).to include "invalid_client"
      end
    end

    context "when the refresh_token field is missing" do
      it "should return an invalid request error" do
        post "/openid_connect/access_tokens", grant_type: "refresh_token",
             client_id: client.client_id, client_secret: client.client_secret
        expect(response.body).to include "'refresh_token' required"
      end
    end

    context "when the client_secret doesn't match" do
      it "should return an invalid client error" do
        post "/openid_connect/access_tokens", grant_type: "refresh_token", refresh_token: auth.refresh_token,
             client_id: client.client_id, client_secret: "client.client_secret"
        expect(response.body).to include "invalid_client"
      end
    end
  end
end
