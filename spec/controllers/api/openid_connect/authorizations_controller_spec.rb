require "spec_helper"

describe Api::OpenidConnect::AuthorizationsController, type: :controller do
  let!(:client) do
    Api::OpenidConnect::OAuthApplication.create!(
      client_name: "Diaspora Test Client", redirect_uris: ["http://localhost:3000/"])
  end
  let!(:client_with_multiple_redirects) do
    Api::OpenidConnect::OAuthApplication.create!(
      client_name: "Diaspora Test Client", redirect_uris: ["http://localhost:3000/", "http://localhost/"])
  end

  # TODO: jhass - "Might want to setup some factories in spec/factories.rb, see factory_girl's docs."

  before do
    sign_in :user, alice
    allow(@controller).to receive(:current_user).and_return(alice)
    Api::OpenidConnect::Scope.create!(name: "openid")
  end

  describe "#new" do
    context "when not yet authorized" do
      context "when valid parameters are passed" do
        render_views
        context "as GET request" do
          it "should return a form page" do
            get :new, client_id: client.client_id, redirect_uri: "http://localhost:3000/", response_type: "id_token",
                scope: "openid", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)
            expect(response.body).to match("Diaspora Test Client")
          end
        end

        context "as POST request" do
          it "should return a form page" do
            post :new, client_id: client.client_id, redirect_uri: "http://localhost:3000/", response_type: "id_token",
                 scope: "openid", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)
            expect(response.body).to match("Diaspora Test Client")
          end
        end
      end

      context "when client id is missing" do
        it "should return an bad request error" do
          post :new, redirect_uri: "http://localhost:3000/", response_type: "id_token",
               scope: "openid", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)
          expect(response.body).to match("bad_request")
        end
      end

      context "when redirect uri is missing" do
        context "when only one redirect URL is pre-registered" do
          it "should return a form pager" do
            # Note this intentionally behavior diverts from OIDC spec http://openid.net/specs/openid-connect-core-1_0.html#AuthRequest
            # When client has only one redirect uri registered, only that redirect uri can be used. Hence,
            # we should implicitly assume the client wants to use that registered URI.
            # See https://github.com/nov/rack-oauth2/blob/master/lib/rack/oauth2/server/authorize.rb#L63
            post :new, client_id: client.client_id, response_type: "id_token",
                 scope: "openid", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)
            expect(response.body).to match("Diaspora Test Client")
          end
        end
      end

      context "when multiple redirect URLs are pre-registered" do
        it "should return an invalid request error" do
          post :new, client_id: client_with_multiple_redirects.client_id, response_type: "id_token",
               scope: "openid", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)
          expect(response.body).to match("bad_request")
        end
      end

      context "when redirect URI does not match pre-registered URIs" do
        it "should return an invalid request error" do
          post :new, client_id: client.client_id, redirect_uri: "http://localhost:2000/",
               response_type: "id_token", scope: "openid", nonce: SecureRandom.hex(16)
          expect(response.body).to match("bad_request")
        end
      end

      context "when an unsupported scope is passed in" do
        it "should return an invalid scope error" do
          post :new, client_id: client.client_id, redirect_uri: "http://localhost:3000/", response_type: "id_token",
               scope: "random", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)
          expect(response.body).to match("error=invalid_scope")
        end
      end

      context "when nonce is missing" do
        it "should return an invalid request error" do
          post :new, client_id: client.client_id, redirect_uri: "http://localhost:3000/",
               response_type: "id_token", scope: "openid", state: SecureRandom.hex(16)
          expect(response.location).to match("error=invalid_request")
        end
      end
    end
    context "when already authorized" do
      let!(:auth) { Api::OpenidConnect::Authorization.find_or_create_by(o_auth_application: client, user: alice) }

      context "when valid parameters are passed" do
        before do
          get :new, client_id: client.client_id, redirect_uri: "http://localhost:3000/", response_type: "id_token",
              scope: "openid", nonce: 413_093_098_3, state: 413_093_098_3
        end

        it "should return the id token in a fragment" do
          expect(response.location).to have_content("id_token=")
          encoded_id_token = response.location[/(?<=id_token=)[^&]+/]
          decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                        Api::OpenidConnect::IdTokenConfig.public_key
          expect(decoded_token.nonce).to eq("4130930983")
          expect(decoded_token.exp).to be > Time.zone.now.utc.to_i
        end

        it "should return the passed in state" do
          expect(response.location).to have_content("state=4130930983")
        end
      end
    end
  end

  describe "#create" do
    context "when id_token token" do
      before do
        get :new, client_id: client.client_id, redirect_uri: "http://localhost:3000/", response_type: "id_token token",
            scope: "openid", nonce: 418_093_098_3, state: 418_093_098_3
      end

      context "when authorization is approved" do
        before do
          post :create, approve: "true"
        end

        it "should return the id token in a fragment" do
          encoded_id_token = response.location[/(?<=id_token=)[^&]+/]
          decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                        Api::OpenidConnect::IdTokenConfig.public_key
          expect(decoded_token.nonce).to eq("4180930983")
          expect(decoded_token.exp).to be > Time.zone.now.utc.to_i
        end

        it "should return a valid access token in a fragment" do
          encoded_id_token = response.location[/(?<=id_token=)[^&]+/]
          decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                        Api::OpenidConnect::IdTokenConfig.public_key
          access_token = response.location[/(?<=access_token=)[^&]+/]
          access_token_check_num = UrlSafeBase64.encode64(OpenSSL::Digest::SHA256.digest(access_token)[0, 128 / 8])
          expect(decoded_token.at_hash).to eq(access_token_check_num)
        end
      end
    end

    context "when id_token" do
      before do
        get :new, client_id: client.client_id, redirect_uri: "http://localhost:3000/", response_type: "id_token",
            scope: "openid", nonce: 418_093_098_3, state: 418_093_098_3
      end

      context "when authorization is approved" do
        before do
          post :create, approve: "true"
        end

        it "should return the id token in a fragment" do
          expect(response.location).to have_content("id_token=")
          encoded_id_token = response.location[/(?<=id_token=)[^&]+/]
          decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                        Api::OpenidConnect::IdTokenConfig.public_key
          expect(decoded_token.nonce).to eq("4180930983")
          expect(decoded_token.exp).to be > Time.zone.now.utc.to_i
        end

        it "should return the passed in state" do
          expect(response.location).to have_content("state=4180930983")
        end
      end

      context "when authorization is denied" do
        before do
          post :create, approve: "false"
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
end
