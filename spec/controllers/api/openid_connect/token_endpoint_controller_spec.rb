# frozen_string_literal: true

describe Api::OpenidConnect::TokenEndpointController, type: :controller, suppress_csrf_verification: :none do
  let(:auth) { FactoryGirl.create(:auth_with_default_scopes) }

  describe "#create" do
    it "returns 200 on success" do
      post :create, params: {
        grant_type:    "authorization_code",
        code:          auth.create_code,
        redirect_uri:  auth.redirect_uri,
        scope:         auth.scopes.join(" "),
        client_id:     auth.o_auth_application.client_id,
        client_secret: auth.o_auth_application.client_secret
      }
      expect(response.code).to eq("200")
    end

    it "refresh returns 200 on success" do
      post :create, params: {
        grant_type:    "refresh_token",
        refresh_token: auth.refresh_token,
        client_id:     auth.o_auth_application.client_id,
        client_secret: auth.o_auth_application.client_secret
      }
      expect(response.code).to eq("200")
    end
  end
end
