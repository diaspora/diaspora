require 'spec_helper'

describe OpenidConnect::ClientsController, type: :controller do
  describe "#create" do
    context "when valid parameters are passed" do
      it "should return a client id" do
        post :create,
             {
               redirect_uris: ["http://localhost"]
             }
        clientJSON = JSON.parse(response.body)
        expect(clientJSON["o_auth_application"]["client_id"].length).to eq(32)
      end
    end
    context "when redirect uri is missing" do
      it "should return a invalid_client_metadata error" do
        post :create
        clientJSON = JSON.parse(response.body)
        expect(clientJSON["error"]).to have_content("invalid_client_metadata")
      end
    end
  end
end
