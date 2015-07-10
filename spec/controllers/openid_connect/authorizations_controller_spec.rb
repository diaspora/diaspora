require 'spec_helper'

describe OpenidConnect::AuthorizationsController, type: :controller do
  let!(:client) { OAuthApplication.create!(name: "Diaspora Test Client", redirect_uris: ["http://localhost:3000/"]) }
  let!(:client_with_multiple_redirects) { OAuthApplication.create!(name: "Diaspora Test Client", redirect_uris: ["http://localhost:3000/","http://localhost/"]) }

  before do
    sign_in :user, alice
    allow(@controller).to receive(:current_user).and_return(alice)
    Scope.create!(name:"openid")
  end

  describe "#new" do
    context "when valid parameters are passed" do
      render_views
      context "as GET request" do
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
          expect(response.body).to match("Diaspora Test Client")
        end
      end
      context "as POST request" do
        it "should return a form page" do
          post :new,
              {
                client_id: client.client_id,
                redirect_uri: "http://localhost:3000/",
                response_type: "id_token",
                scope: "openid",
                nonce: SecureRandom.hex(16),
                state: SecureRandom.hex(16)
              }
          expect(response.body).to match("Diaspora Test Client")
        end
      end
    end
    context "when client id is missing" do
      it "should return an bad request error" do
        post :new,
             {
               redirect_uri: "http://localhost:3000/",
               response_type: "id_token",
               scope: "openid",
               nonce: SecureRandom.hex(16),
               state: SecureRandom.hex(16)
             }
        expect(response.body).to match("bad_request")
      end
    end
    context "when redirect uri is missing" do
      context "when only one redirect URL is pre-registered" do
        it "should return a form pager" do
          # Note this intentionally behavior diverts from OIDC spec http://openid.net/specs/openid-connect-core-1_0.html#AuthRequest
          # See https://github.com/nov/rack-oauth2/blob/master/lib/rack/oauth2/server/authorize.rb#L63
          post :new,
               {
                 client_id: client.client_id,
                 response_type: "id_token",
                 scope: "openid",
                 nonce: SecureRandom.hex(16),
                 state: SecureRandom.hex(16)
               }
          expect(response.body).to match("Diaspora Test Client")
        end
      end
    end
    context "when multiple redirect URLs are pre-registered" do
      it "should return an invalid request error" do
        post :new,
             {
               client_id: client_with_multiple_redirects.client_id,
               response_type: "id_token",
               scope: "openid",
               nonce: SecureRandom.hex(16),
               state: SecureRandom.hex(16)
             }
        expect(response.body).to match("bad_request")
      end
    end
    context "when redirect URI does not match pre-registered URIs" do
      it "should return an invalid request error" do
        post :new,
             {
               client_id: client.client_id,
               redirect_uri: "http://localhost:2000/",
               response_type: "id_token",
               scope: "openid",
               nonce: SecureRandom.hex(16)
             }
        expect(response.body).to match("bad_request")
      end
    end
    context "when an unsupported scope is passed in" do
      it "should return an invalid scope error" do
        post :new,
             {
               client_id: client.client_id,
               redirect_uri: "http://localhost:3000/",
               response_type: "id_token",
               scope: "random",
               nonce: SecureRandom.hex(16),
               state: SecureRandom.hex(16)
             }
        expect(response.body).to match("error=invalid_scope")
      end
    end
    context "when nonce is missing" do
      it "should return an invalid request error" do
        post :new,
             {
               client_id: client.client_id,
               redirect_uri: "http://localhost:3000/",
               response_type: "id_token",
               scope: "openid",
               state: SecureRandom.hex(16)
             }
        expect(response.location).to match("error=invalid_request")
      end
    end
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
            state: 4180930983
          }
    end
    context "when authorization is approved" do
      before do
        post :create,
             {
               approve: "true"
             }
      end
      it "should return the id token in a fragment" do
        expect(response.location).to have_content("id_token=")
      end
      it "should return the passed in state" do
        expect(response.location).to have_content("state=4180930983")
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
        expect(response.location).to have_content("error=")
      end
      it "should NOT contain a id token in the fragment" do
        expect(response.location).to_not have_content("id_token=")
      end
    end
  end

end
