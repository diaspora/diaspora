require "spec_helper"

describe Api::OpenidConnect::TokenEndpoint, type: :request do
  let!(:client) do
    Api::OpenidConnect::OAuthApplication.create!(
      redirect_uris: ["http://localhost:3000/"], client_name: "diaspora client",
      ppid: true, sector_identifier_uri: "https://example.com/uri")
  end
  let!(:auth) {
    Api::OpenidConnect::Authorization.find_or_create_by(
      o_auth_application: client, user: bob, redirect_uri: "http://localhost:3000/")
  }
  let!(:code) { auth.create_code }

  before do
    Api::OpenidConnect::Scope.find_or_create_by(name: "read")
  end

  describe "the authorization code grant type" do
    context "when the authorization code is valid" do
      before do
        post api_openid_connect_access_tokens_path, grant_type: "authorization_code",
             client_id: client.client_id, client_secret: client.client_secret,
             redirect_uri: "http://localhost:3000/", code: code
      end

      it "should return a valid id token" do
        json = JSON.parse(response.body)
        encoded_id_token = json["id_token"]
        decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                      Api::OpenidConnect::IdTokenConfig.public_key
        expected_guid = bob.pairwise_pseudonymous_identifiers.find_by(sector_identifier: "https://example.com/uri").guid
        expect(decoded_token.sub).to eq(expected_guid)
        expect(decoded_token.exp).to be > Time.zone.now.utc.to_i
      end

      it "should return a valid access token" do
        json = JSON.parse(response.body)
        encoded_id_token = json["id_token"]
        decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                      Api::OpenidConnect::IdTokenConfig.public_key
        access_token = json["access_token"]
        access_token_check_num = UrlSafeBase64.encode64(OpenSSL::Digest::SHA256.digest(access_token)[0, 128 / 8])
        expect(decoded_token.at_hash).to eq(access_token_check_num)
      end
    end

    context "when the authorization code is not valid" do
      it "should return an invalid grant error" do
        post api_openid_connect_access_tokens_path, grant_type: "authorization_code",
             client_id: client.client_id, client_secret: client.client_secret, code: "123456"
        expect(response.body).to include "invalid_grant"
      end
    end

    context "when the client is unregistered" do
      it "should return an error" do
        post api_openid_connect_access_tokens_path, grant_type: "authorization_code", code: auth.refresh_token,
             client_id: SecureRandom.hex(16).to_s, client_secret: client.client_secret
        expect(response.body).to include "invalid_client"
      end
    end

    context "when the code field is missing" do
      it "should return an invalid request error" do
        post api_openid_connect_access_tokens_path, grant_type: "authorization_code",
             client_id: client.client_id, client_secret: client.client_secret
        expect(response.body).to include "invalid_request"
      end
    end

    context "when the client_secret doesn't match" do
      it "should return an invalid client error" do
        post api_openid_connect_access_tokens_path, grant_type: "authorization_code", code: auth.refresh_token,
             client_id: client.client_id, client_secret: "client.client_secret"
        expect(response.body).to include "invalid_client"
      end
    end
  end

  describe "an unsupported grant type" do
    it "should return an unsupported grant type error" do
      post api_openid_connect_access_tokens_path, grant_type: "noexistgrant", username: "bob",
           password: "bluepin7", client_id: client.client_id, client_secret: client.client_secret, scope: "read"
      expect(response.body).to include "unsupported_grant_type"
    end
  end

  describe "the refresh token grant type" do
    context "when the refresh token is valid" do
      it "should return an access token" do
        post api_openid_connect_access_tokens_path, grant_type: "refresh_token",
             client_id: client.client_id, client_secret: client.client_secret, refresh_token: auth.refresh_token
        json = JSON.parse(response.body)
        expect(response.body).to include "expires_in"
        expect(json["access_token"].length).to eq(64)
        expect(json["token_type"]).to eq("bearer")
      end
    end

    context "when the refresh token is not valid" do
      it "should return an invalid grant error" do
        post api_openid_connect_access_tokens_path, grant_type: "refresh_token",
             client_id: client.client_id, client_secret: client.client_secret, refresh_token: "123456"
        expect(response.body).to include "invalid_grant"
      end
    end

    context "when the client is unregistered" do
      it "should return an error" do
        post api_openid_connect_access_tokens_path, grant_type: "refresh_token", refresh_token: auth.refresh_token,
             client_id: SecureRandom.hex(16).to_s, client_secret: client.client_secret
        expect(response.body).to include "invalid_client"
      end
    end

    context "when the refresh_token field is missing" do
      it "should return an invalid request error" do
        post api_openid_connect_access_tokens_path, grant_type: "refresh_token",
             client_id: client.client_id, client_secret: client.client_secret
        expect(response.body).to include "'refresh_token' required"
      end
    end

    context "when the client_secret doesn't match" do
      it "should return an invalid client error" do
        post api_openid_connect_access_tokens_path, grant_type: "refresh_token", refresh_token: auth.refresh_token,
             client_id: client.client_id, client_secret: "client.client_secret"
        expect(response.body).to include "invalid_client"
      end
    end
  end
end
