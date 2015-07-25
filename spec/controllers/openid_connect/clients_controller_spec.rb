require "spec_helper"

describe OpenidConnect::ClientsController, type: :controller do
  describe "#create" do
    context "when valid parameters are passed" do
      it "should return a client id" do
        post :create, redirect_uris: ["http://localhost"], client_name: "diaspora client",
             response_types: [], grant_types: [], application_type: "web", contacts: [],
             logo_uri: "http://test.com/logo.png", client_uri: "http://test.com/client",
             policy_uri: "http://test.com/policy", tos_uri: "http://test.com/tos"
        client_json = JSON.parse(response.body)
        expect(client_json["o_auth_application"]["client_id"].length).to eq(32)
      end
    end
    context "when redirect uri is missing" do
      it "should return a invalid_client_metadata error" do
        post :create, response_types: [], grant_types: [], application_type: "web", contacts: [],
          logo_uri: "http://test.com/logo.png", client_uri: "http://test.com/client",
          policy_uri: "http://test.com/policy", tos_uri: "http://test.com/tos"
        client_json = JSON.parse(response.body)
        expect(client_json["error"]).to have_content("invalid_client_metadata")
      end
    end
    context "when redirect client_name is missing" do
      it "should return a invalid_client_metadata error" do
        post :create, redirect_uris: ["http://localhost"], response_types: [], grant_types: [],
             application_type: "web", contacts: [], logo_uri: "http://test.com/logo.png",
             client_uri: "http://test.com/client", policy_uri: "http://test.com/policy", tos_uri: "http://test.com/tos"
        client_json = JSON.parse(response.body)
        expect(client_json["error"]).to have_content("invalid_client_metadata")
      end
    end
  end
end
