require "spec_helper"

describe Api::OpenidConnect::ClientsController, type: :controller do
  describe "#create" do
    context "when valid parameters are passed" do
      it "should return a client id" do
        post :create, redirect_uris: ["http://localhost"], client_name: "diaspora client",
             response_types: [], grant_types: [], application_type: "web", contacts: [],
             logo_uri: "http://example.com/logo.png", client_uri: "http://example.com/client",
             policy_uri: "http://example.com/policy", tos_uri: "http://example.com/tos",
             sector_identifier_uri: "http://example.com/uris", subject_type: "pairwise"
        client_json = JSON.parse(response.body)
        expect(client_json["client_id"].length).to eq(32)
        expect(client_json["ppid"]).to eq(true)
      end
    end
    context "when redirect uri is missing" do
      it "should return a invalid_client_metadata error" do
        post :create, response_types: [], grant_types: [], application_type: "web", contacts: [],
          logo_uri: "http://example.com/logo.png", client_uri: "http://example.com/client",
          policy_uri: "http://example.com/policy", tos_uri: "http://example.com/tos"
        client_json = JSON.parse(response.body)
        expect(client_json["error"]).to have_content("invalid_client_metadata")
      end
    end
    context "when redirect client_name is missing" do
      it "should return a invalid_client_metadata error" do
        post :create, redirect_uris: ["http://localhost"], response_types: [], grant_types: [],
             application_type: "web", contacts: [], logo_uri: "http://example.com/logo.png",
             client_uri: "http://example.com/client", policy_uri: "http://example.com/policy",
             tos_uri: "http://example.com/tos"
        client_json = JSON.parse(response.body)
        expect(client_json["error"]).to have_content("invalid_client_metadata")
      end
    end
  end
end
