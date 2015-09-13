require 'spec_helper'

describe "Token Endpoint", type: :request do
  describe "password grant type" do
    context "when the username field is missing" do
      it "should return an invalid request error" do
        post "/openid/access_tokens?grant_type=password\&password=bluepin7\&client_id=4\&client_secret=azerty"
        expect(response.body).to include("'username' required")
      end
    end
    context "when the password field is missing" do
      it "should return an invalid request error" do
        post "/openid/access_tokens?grant_type=password\&username=bob\&client_id=4\&client_secret=azerty"
        expect(response.body).to include("'password' required")
      end
    end
    context "when the username does not match an existing user" do
      it "should return an invalid request error" do
        post "/openid/access_tokens?grant_type=password\&username=mewasdfrandom\&password=bluepin7\&client_id=4\&client_secret=azerty"
        expect(response.body).to include("invalid_grant")
      end
    end
    context "when the password is invalid" do
      it "should return an invalid request error" do
        post "/openid/access_tokens?grant_type=password\&username=mewasdfrandom\&password=bluepin7\&client_id=4\&client_secret=azerty"
        expect(response.body).to include("invalid_grant")
      end
    end
    context "when there are duplicate fields" do
      it "should return an invalid request error" do
        post "/openid/access_tokens?grant_type=password\&username=bob\&password=bluepin6\&username=bob\&password=bluepin7\&client_id=4\&client_secret=azerty"
        expect(response.body).to include("invalid_grant")
        # TODO: Apparently Nov's implementation lets this one pass; however, according to the OIDC spec, we are supposed to reject duplicate fields. Is this a security issue?
      end
    end
    context "when the client is unauthorized" do
      # TODO: If we support password grant, we should prevent access from unauthorized client applications
      it "should return an error" do
        fail
      end
    end
    context "when many unauthorized requests are made" do
      # TODO: If we support password grant, we should support a way to prevent brute force attacks (using rate-limitation or generating alerts) as specified by RFC 6749 4.3.2 Access Token Request
      it "should generate an alert" do
        fail
      end
    end
    context "when the request is valid" do
      it "should return an access token" do
        post "/openid/access_tokens?grant_type=password\&username=bob\&password=bluepin7\&client_id=4\&client_secret=azerty"
        json = JSON.parse(response.body)
        expect(json["access_token"].length).to eq(64)
        expect(json["token_type"]).to eq("bearer")
        expect(json.keys).to include("expires_in")
      end
    end
  end
  describe "unsupported grant type" do
    it "should return an unsupported grant type error" do
      post "/openid/access_tokens?grant_type=me\&username=bob\&password=bluepin7\&client_id=4\&client_secret=azerty"
      expect(response.body).to include "unsupported_grant_type"
    end
  end
end
