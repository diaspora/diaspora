# frozen_string_literal: true

describe Api::OpenidConnect::TokenEndpoint, type: :request do
  let!(:client) { FactoryGirl.create(:o_auth_application_with_ppid) }
  let!(:auth) {
    Api::OpenidConnect::Authorization.find_or_create_by(
      o_auth_application: client, user: bob, redirect_uri: "http://localhost:3000/", scopes: ["openid"])
  }
  let!(:code) { auth.create_code }
  let!(:client_with_specific_id) { FactoryGirl.create(:o_auth_application_with_ppid) }
  let!(:auth_with_specific_id) do
    client_with_specific_id.client_id = "14d692cd53d9c1a9f46fd69e0e57443e"
    client_with_specific_id.jwks = File.read(jwks_file_path)
    client_with_specific_id.save!
    Api::OpenidConnect::Authorization.find_or_create_by(
      o_auth_application: client_with_specific_id,
      user: bob, redirect_uri: "http://localhost:3000/", scopes: ["openid"])
  end
  let!(:code_with_specific_id) { auth_with_specific_id.create_code }

  describe "the authorization code grant type" do
    context "when the authorization code is valid" do
      before do
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code",
             client_id: client.client_id, client_secret: client.client_secret,
             redirect_uri: "http://localhost:3000/", code: code}
      end

      it "should return a valid id token" do
        json = JSON.parse(response.body)
        encoded_id_token = json["id_token"]
        decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                      Api::OpenidConnect::IdTokenConfig::PUBLIC_KEY
        expected_guid = bob.pairwise_pseudonymous_identifiers.find_by(identifier: "https://example.com/uri").guid
        expect(decoded_token.sub).to eq(expected_guid)
        expect(decoded_token.exp).to be > Time.zone.now.utc.to_i
      end

      it "should return an id token with a kid" do
        json = JSON.parse(response.body)
        encoded_id_token = json["id_token"]
        kid = JSON::JWT.decode(encoded_id_token, :skip_verification).header[:kid]
        expect(kid).to eq("default")
      end

      it "should return a valid access token" do
        json = JSON.parse(response.body)
        encoded_id_token = json["id_token"]
        decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                      Api::OpenidConnect::IdTokenConfig::PUBLIC_KEY
        access_token = json["access_token"]
        access_token_check_num = Base64.urlsafe_encode64(
          OpenSSL::Digest::SHA256.digest(access_token)[0, 128 / 8], padding: false
        )
        expect(decoded_token.at_hash).to eq(access_token_check_num)
      end

      it "should not allow code to be reused" do
        auth.reload
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code",
             client_id: client.client_id, client_secret: client.client_secret,
             redirect_uri: "http://localhost:3000/", code: code}
        expect(JSON.parse(response.body)["error"]).to eq("invalid_grant")
      end

      it "should not allow a nil code" do
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code",
             client_id: client.client_id, client_secret: client.client_secret,
             redirect_uri: "http://localhost:3000/", code: nil}
        expect(JSON.parse(response.body)["error"]).to eq("invalid_request")
      end
    end

    context "when the authorization code is valid with jwt bearer" do
      before do
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code",
             redirect_uri: "http://localhost:3000/", code: code_with_specific_id,
             client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
             client_assertion: File.read(valid_client_assertion_path)}
      end

      it "should return a valid id token" do
        json = JSON.parse(response.body)
        encoded_id_token = json["id_token"]
        decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                      Api::OpenidConnect::IdTokenConfig::PUBLIC_KEY
        expected_guid = bob.pairwise_pseudonymous_identifiers.find_by(identifier: "https://example.com/uri").guid
        expect(decoded_token.sub).to eq(expected_guid)
        expect(decoded_token.exp).to be > Time.zone.now.utc.to_i
      end

      it "should return a valid access token" do
        json = JSON.parse(response.body)
        encoded_id_token = json["id_token"]
        decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                      Api::OpenidConnect::IdTokenConfig::PUBLIC_KEY
        access_token = json["access_token"]
        access_token_check_num = Base64.urlsafe_encode64(
          OpenSSL::Digest::SHA256.digest(access_token)[0, 128 / 8], padding: false
        )
        expect(decoded_token.at_hash).to eq(access_token_check_num)
      end

      it "should not allow code to be reused" do
        auth_with_specific_id.reload
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code",
             client_id: client.client_id, client_secret: client.client_secret,
             redirect_uri: "http://localhost:3000/", code: code_with_specific_id}
        expect(JSON.parse(response.body)["error"]).to eq("invalid_grant")
      end
    end

    context "when the authorization code is not valid" do
      it "should return an invalid grant error" do
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code",
             client_id: client.client_id, client_secret: client.client_secret, code: "123456"}
        expect(response.body).to include "invalid_grant"
      end
    end

    context "when the client assertion is in an invalid format" do
      before do
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code",
             redirect_uri: "http://localhost:3000/", code: code_with_specific_id,
             client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
             client_assertion: "invalid_client_assertion.random"}
      end

      it "should return an error" do
        expect(response.body).to include "invalid_request"
      end
    end

    context "when the client assertion is not matching with jwks keys" do
      before do
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code",
             redirect_uri: "http://localhost:3000/", code: code_with_specific_id,
             client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
             client_assertion: File.read(client_assertion_with_tampered_sig_path)}
      end

      it "should return an error" do
        expect(response.body).to include "invalid_grant"
      end
    end

    context "when kid doesn't exist in jwks keys" do
      before do
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code",
             redirect_uri: "http://localhost:3000/", code: code_with_specific_id,
             client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
             client_assertion: File.read(client_assertion_with_nonexistent_kid_path)}
      end

      it "should return an error" do
        expect(response.body).to include "invalid_request"
      end
    end

    context "when the client is unregistered" do
      it "should return an error" do
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code", code: auth.refresh_token,
             client_id: SecureRandom.hex(16).to_s, client_secret: client.client_secret}
        expect(response.body).to include "invalid_client"
      end
    end

    context "when the client is unregistered with jwks keys" do
      before do
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code",
             redirect_uri: "http://localhost:3000/", code: code_with_specific_id,
             client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
             client_assertion: File.read(client_assertion_with_nonexistent_client_id_path)}
      end

      it "should return an error" do
        expect(response.body).to include "invalid_request"
      end
    end

    context "when the code field is missing" do
      it "should return an invalid request error" do
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code",
             client_id: client.client_id, client_secret: client.client_secret}
        expect(response.body).to include "invalid_request"
      end
    end

    context "when the client_secret doesn't match" do
      it "should return an invalid client error" do
        post api_openid_connect_access_tokens_path, params: {grant_type: "authorization_code", code: auth.refresh_token,
             client_id: client.client_id, client_secret: "client.client_secret"}
        expect(response.body).to include "invalid_client"
      end
    end
  end

  describe "an unsupported grant type" do
    it "should return an unsupported grant type error" do
      post api_openid_connect_access_tokens_path, params: {grant_type: "noexistgrant", username: "bob",
           password: "bluepin7", client_id: client.client_id, client_secret: client.client_secret, scope: "read"}
      expect(response.body).to include "unsupported_grant_type"
    end
  end

  describe "the refresh token grant type" do
    context "when the refresh token is valid" do
      it "should return an access token" do
        post api_openid_connect_access_tokens_path, params: {grant_type: "refresh_token",
             client_id: client.client_id, client_secret: client.client_secret, refresh_token: auth.refresh_token}
        json = JSON.parse(response.body)
        expect(response.body).to include "expires_in"
        expect(json["access_token"].length).to eq(64)
        expect(json["token_type"]).to eq("bearer")
      end
    end

    context "when the refresh token is not valid" do
      it "should return an invalid grant error" do
        post api_openid_connect_access_tokens_path, params: {grant_type: "refresh_token",
             client_id: client.client_id, client_secret: client.client_secret, refresh_token: "123456"}
        expect(response.body).to include "invalid_grant"
      end
    end

    context "when the client is unregistered" do
      it "should return an error" do
        post api_openid_connect_access_tokens_path, params: {grant_type: "refresh_token",
             refresh_token: auth.refresh_token,
             client_id: SecureRandom.hex(16).to_s, client_secret: client.client_secret}
        expect(response.body).to include "invalid_client"
      end
    end

    context "when the refresh_token field is missing" do
      it "should return an invalid request error" do
        post api_openid_connect_access_tokens_path, params: {grant_type: "refresh_token",
             client_id: client.client_id, client_secret: client.client_secret}
        expect(response.body).to include "'refresh_token' required"
      end
    end

    context "when the client_secret doesn't match" do
      it "should return an invalid client error" do
        post api_openid_connect_access_tokens_path, params: {grant_type: "refresh_token",
             refresh_token: auth.refresh_token,
             client_id: client.client_id, client_secret: "client.client_secret"}
        expect(response.body).to include "invalid_client"
      end
    end
  end
end
