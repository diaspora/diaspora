require 'spec_helper'

describe OpenidConnect::AuthorizationsController, type: :controller do
  let!(:client) { OAuthApplication.create!(redirect_uris: ["http://localhost:3000/"]) }

  before do
    sign_in :user, alice
    allow(@controller).to receive(:current_user).and_return(alice)
    Scope.create!(name:"openid")
  end

  describe "#new" do
    render_views
    context "when valid parameters are passed" do
      it "should return a form page" do
        get :new,
             {
               client_id: client.client_id,
               redirect_uri: "http://localhost:3000/",
               response_type: "id_token",
               scope: "openid",
               nonce: SecureRandom.hex(16),
               state: SecureRandom.hex(16)
             }
        expect(response.body).to match("Approve")
        expect(response.body).to match("Deny")
      end
    end
    # TODO: Implement tests for missing/invalid parameters
  end

  describe "#create" do
    before do
      get :new,
          {
            client_id: client.client_id,
            redirect_uri: "http://localhost:3000/",
            response_type: "id_token",
            scope: "openid",
            nonce: SecureRandom.hex(16),
            state: SecureRandom.hex(16)
          }
    end
    context "when authorization is approved" do
      it "should return the id token in a fragment" do
        post :create,
             {
               approve: "true"
             }
        expect(response.location).to have_content("#id_token=")
      end
    end
    context "when authorization is denied" do
      before do
        post :create,
             {
               approve: "false"
             }
      end
      it "should return an error in the fragment" do
        expect(response.location).to have_content("#error=")
      end
      it "should NOT contain a id token in the fragment" do
        expect(response.location).to_not have_content("#id_token=")
      end
    end
  end

end
