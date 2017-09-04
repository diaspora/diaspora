# frozen_string_literal: true

describe Api::OpenidConnect::AuthorizationsController, type: :request do
  let!(:client) { FactoryGirl.create(:o_auth_application) }

  before do
    sign_in alice, scope: :user
  end

  describe "#new" do
    context "when not yet authorized" do
      context "when valid parameters are passed" do
        context "as GET request" do
          it "should return a form page" do
            get new_api_openid_connect_authorization_path, params: {client_id: client.client_id,
                redirect_uri: "http://localhost:3000/", response_type: "id_token",
                scope: "openid", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)}
            expect(response.body).to match("Diaspora Test Client")
          end
        end

        context "using claims" do
          it "should return a form page" do
            get new_api_openid_connect_authorization_path, params: {client_id: client.client_id,
                redirect_uri: "http://localhost:3000/", response_type: "id_token",
                scope: "openid", claims: "{\"userinfo\": {\"name\": {\"essential\": true}}}",
                nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)}
            expect(response.body).to match("Diaspora Test Client")
          end
        end

        context "as a request object" do
          it "should return a form page" do
            header = JWT.encoded_header("none")
            payload_hash = {client_id: client.client_id, redirect_uri: "http://localhost:3000/",
                            response_type: "id_token", scope: "openid", nonce: "hello", state: "hello",
                            claims: {userinfo: {name: {essential: true}}}}
            payload = JWT.encoded_payload(JSON.parse(payload_hash.to_json))
            request_object = header + "." + payload + "."
            get new_api_openid_connect_authorization_path, params: {client_id: client.client_id,
                redirect_uri: "http://localhost:3000/", response_type: "id_token",
                scope: "openid", nonce: "hello", state: "hello", request: request_object}
            expect(response.body).to match("Diaspora Test Client")
          end
        end

        context "as a request object with no claims" do
          it "should return a form page" do
            header = JWT.encoded_header("none")
            payload_hash = {client_id: client.client_id, redirect_uri: "http://localhost:3000/",
                             response_type: "id_token", scope: "openid", nonce: "hello", state: "hello"}
            payload = JWT.encoded_payload(JSON.parse(payload_hash.to_json))
            request_object = header + "." + payload + "."
            get new_api_openid_connect_authorization_path, params: {client_id: client.client_id,
                redirect_uri: "http://localhost:3000/", response_type: "id_token",
                scope: "openid", nonce: "hello", state: "hello", request: request_object}
            expect(response.body).to match("Diaspora Test Client")
          end
        end

        context "as POST request" do
          it "should return a form page" do
            post api_openid_connect_authorizations_new_path, params: {client_id: client.client_id,
                 redirect_uri: "http://localhost:3000/", response_type: "id_token",
                 scope: "openid", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)}
            expect(response.body).to match("Diaspora Test Client")
          end
        end
      end

      context "when client id is missing" do
        it "should return an bad request error" do
          post api_openid_connect_authorizations_new_path, params: {redirect_uri: "http://localhost:3000/",
               response_type: "id_token", scope: "openid", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)}
          expect(response.body).to include("The request was malformed")
        end
      end

      context "when redirect uri is missing" do
        context "when only one redirect URL is pre-registered" do
          it "should return a form page" do
            # Note this intentionally behavior diverts from OIDC spec http://openid.net/specs/openid-connect-core-1_0.html#AuthRequest
            # When client has only one redirect uri registered, only that redirect uri can be used. Hence,
            # we should implicitly assume the client wants to use that registered URI.
            # See https://github.com/nov/rack-oauth2/blob/master/lib/rack/oauth2/server/authorize.rb#L63
            post api_openid_connect_authorizations_new_path, params: {client_id: client.client_id,
                 response_type: "id_token", scope: "openid", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)}
            expect(response.body).to match("Diaspora Test Client")
          end
        end
      end

      context "when multiple redirect URLs are pre-registered" do
        it "should return an invalid request error" do
          client_with_multiple_redirects =
            FactoryGirl.create(:o_auth_application, redirect_uris: %w[http://localhost:3000/ http://localhost/])
          post api_openid_connect_authorizations_new_path, params: {client_id: client_with_multiple_redirects.client_id,
               response_type: "id_token", scope: "openid", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)}
          expect(response.body).to include("The request was malformed")
        end
      end

      context "when redirect URI does not match pre-registered URIs" do
        it "should return an invalid request error" do
          post api_openid_connect_authorizations_new_path, params: {client_id: client.client_id,
               redirect_uri: "http://localhost:2000/",
               response_type: "id_token", scope: "openid", nonce: SecureRandom.hex(16)}
          expect(response.body).to include("Invalid client id or redirect uri")
        end
      end

      context "when an unsupported scope is passed in" do
        it "should return an invalid scope error" do
          post api_openid_connect_authorizations_new_path, params: {client_id: client.client_id,
               redirect_uri: "http://localhost:3000/", response_type: "id_token",
               scope: "random", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)}
          expect(response.body).to match("error=invalid_scope")
        end
      end

      context "when nonce is missing" do
        it "should return an invalid request error" do
          post api_openid_connect_authorizations_new_path, params: {client_id: client.client_id,
               redirect_uri: "http://localhost:3000/",
               response_type: "id_token", scope: "openid", state: SecureRandom.hex(16)}
          expect(response.location).to match("error=invalid_request")
        end
      end

      context "when prompt is none" do
        it "should return an interaction required error" do
          post api_openid_connect_authorizations_new_path, params: {client_id: client.client_id,
               redirect_uri: "http://localhost:3000/",
               response_type: "id_token", scope: "openid", state: 1234, display: "page", prompt: "none"}
          expect(response.body).to include("User must already be authorized when `prompt` is `none`")
        end
      end

      context "when prompt is none and user not signed in" do
        before do
          sign_out :user
        end

        it "should return an interaction required error" do
          post api_openid_connect_authorizations_new_path, params: {client_id: client.client_id,
               redirect_uri: "http://localhost:3000/",
               response_type: "id_token", scope: "openid", state: 1234, display: "page", prompt: "none"}
          expect(response.body).to include("User must already be logged in when `prompt` is `none`")
        end
      end

      context "when prompt is none and consent" do
        it "should return an interaction required error" do
          post api_openid_connect_authorizations_new_path, params: {client_id: client.client_id,
               redirect_uri: "http://localhost:3000/",
               response_type: "id_token", scope: "openid", state: 1234, display: "page", prompt: "none consent"}
          expect(response.location).to match("error=invalid_request")
        end
      end

      context "when prompt is select_account" do
        it "should return an account_selection_required error" do
          post api_openid_connect_authorizations_new_path, params: {client_id: client.client_id,
               redirect_uri: "http://localhost:3000/",
               response_type: "id_token", scope: "openid", state: 1234, display: "page", prompt: "select_account"}
          expect(response.location).to match("error=account_selection_required")
          expect(response.location).to match("state=1234")
        end
      end

      context "when prompt is none and client ID is invalid" do
        it "should return an account_selection_required error" do
          post api_openid_connect_authorizations_new_path, params: {client_id: "random",
               redirect_uri: "http://localhost:3000/", response_type: "id_token", scope: "openid", state: 1234,
               display: "page", prompt: "none"}
          expect(response.body).to include("Invalid client id or redirect uri")
        end
      end

      context "when prompt is none and redirect URI does not match pre-registered URIs" do
        it "should return an account_selection_required error" do
          post api_openid_connect_authorizations_new_path, params: {client_id: client.client_id,
               redirect_uri: "http://randomuri:3000/",
               response_type: "id_token", scope: "openid", state: 1234, display: "page", prompt: "none"}
          expect(response.body).to include("Invalid client id or redirect uri")
        end
      end

      context "when XSS script is passed as name" do
        it "should escape html" do
          client_with_xss = FactoryGirl.create(:o_auth_application_with_xss)
          post api_openid_connect_authorizations_new_path, params: {client_id: client_with_xss.client_id,
               redirect_uri: "http://localhost:3000/",
               response_type: "id_token", scope: "openid", nonce: SecureRandom.hex(16), state: SecureRandom.hex(16)}
          expect(response.body).to_not include("<script>alert(0);</script>")
        end
      end
    end

    context "when already authorized" do
      before do
        Api::OpenidConnect::Authorization.create!(
          o_auth_application: client, user: alice, redirect_uri: "http://localhost:3000/", scopes: ["openid"])
      end

      context "when valid parameters are passed" do
        before do
          get new_api_openid_connect_authorization_path, params: {client_id: client.client_id,
              redirect_uri: "http://localhost:3000/", response_type: "id_token",
              scope: "openid", nonce: 413_093_098_3, state: 413_093_098_3}
        end

        it "should return the id token in a fragment" do
          expect(response.location).to include("id_token=")
          encoded_id_token = response.location[/(?<=id_token=)[^&]+/]
          decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                        Api::OpenidConnect::IdTokenConfig::PUBLIC_KEY
          expect(decoded_token.nonce).to eq("4130930983")
          expect(decoded_token.exp).to be > Time.zone.now.utc.to_i
        end

        it "should return the passed in state" do
          expect(response.location).to include("state=4130930983")
        end
      end

      context "when prompt is none" do
        it "should return the id token in a fragment" do
          post api_openid_connect_authorizations_new_path, params: {client_id: client.client_id,
               redirect_uri: "http://localhost:3000/",
               response_type: "id_token", scope: "openid", nonce: 413_093_098_3, state: 413_093_098_3,
               display: "page", prompt: "none"}
          expect(response.location).to include("id_token=")
          encoded_id_token = response.location[/(?<=id_token=)[^&]+/]
          decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                        Api::OpenidConnect::IdTokenConfig::PUBLIC_KEY
          expect(decoded_token.nonce).to eq("4130930983")
          expect(decoded_token.exp).to be > Time.zone.now.utc.to_i
        end
      end

      context "when prompt contains consent" do
        it "should return a consent form page" do
          get new_api_openid_connect_authorization_path, params: {client_id: client.client_id,
              redirect_uri: "http://localhost:3000/",
              response_type: "id_token", scope: "openid", nonce: 413_093_098_3, state: 413_093_098_3,
              display: "page", prompt: "consent"}
          expect(response.body).to match("Diaspora Test Client")
        end
      end

      context "when scopes are escalated" do
        before do
          get new_api_openid_connect_authorization_path, params: {client_id: client.client_id,
              redirect_uri: "http://localhost:3000/", response_type: "id_token",
              scope: "openid read", nonce: 413_093_098_3, state: 413_093_098_3}
        end

        it "should receive another authorization request" do
          expect(response.body).to match("Diaspora Test Client")
        end

        it "should overwrite old authorization scope after approval" do
          post api_openid_connect_authorizations_path, params: {approve: "true"}
          authorization_with_old_scope =
            Api::OpenidConnect::Authorization.find_by_client_id_user_and_scopes(client.client_id, alice, ["openid"])
          expect(authorization_with_old_scope).to be_nil
        end
      end
    end
  end

  describe "#create" do
    context "when id_token token" do
      before do
        get new_api_openid_connect_authorization_path, params: {client_id: client.client_id,
            redirect_uri: "http://localhost:3000/", response_type: "id_token token",
            scope: "openid", nonce: 418_093_098_3, state: 418_093_098_3}
      end

      context "when authorization is approved" do
        before do
          post api_openid_connect_authorizations_path, params: {approve: "true"}
        end

        it "should return the id token in a fragment" do
          encoded_id_token = response.location[/(?<=id_token=)[^&]+/]
          decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                        Api::OpenidConnect::IdTokenConfig::PUBLIC_KEY
          expect(decoded_token.nonce).to eq("4180930983")
          expect(decoded_token.exp).to be > Time.zone.now.utc.to_i
        end

        it "should return a valid access token in a fragment" do
          encoded_id_token = response.location[/(?<=id_token=)[^&]+/]
          decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                        Api::OpenidConnect::IdTokenConfig::PUBLIC_KEY
          access_token = response.location[/(?<=access_token=)[^&]+/]
          access_token_check_num = UrlSafeBase64.encode64(OpenSSL::Digest::SHA256.digest(access_token)[0, 128 / 8])
          expect(decoded_token.at_hash).to eq(access_token_check_num)
        end
      end
    end

    context "when id_token" do
      before do
        get new_api_openid_connect_authorization_path, params: {client_id: client.client_id,
            redirect_uri: "http://localhost:3000/", response_type: "id_token",
            scope: "openid", nonce: 418_093_098_3, state: 418_093_098_3}
      end

      context "when authorization is approved" do
        before do
          post api_openid_connect_authorizations_path, params: {approve: "true"}
        end

        it "should return the id token in a fragment" do
          expect(response.location).to include("id_token=")
          encoded_id_token = response.location[/(?<=id_token=)[^&]+/]
          decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                        Api::OpenidConnect::IdTokenConfig::PUBLIC_KEY
          expect(decoded_token.nonce).to eq("4180930983")
          expect(decoded_token.exp).to be > Time.zone.now.utc.to_i
        end

        it "should return the passed in state" do
          expect(response.location).to include("state=4180930983")
        end
      end

      context "when authorization is denied" do
        before do
          post api_openid_connect_authorizations_path, params: {approve: "false"}
        end

        it "should return an error in the fragment" do
          expect(response.location).to include("error=")
        end

        it "should NOT contain a id token in the fragment" do
          expect(response.location).to_not include("id_token=")
        end
      end
    end

    context "when code" do
      before do
        get new_api_openid_connect_authorization_path, params: {client_id: client.client_id,
            redirect_uri: "http://localhost:3000/", response_type: "code",
            scope: "openid", nonce: 418_093_098_3, state: 418_093_098_3}
      end

      context "when authorization is approved" do
        before do
          post api_openid_connect_authorizations_path, params: {approve: "true"}
        end

        it "should return the code" do
          expect(response.location).to include("code")
        end

        it "should return the passed in state" do
          expect(response.location).to include("state=4180930983")
        end
      end

      context "when authorization is denied" do
        before do
          post api_openid_connect_authorizations_path, params: {approve: "false"}
        end

        it "should return an error" do
          expect(response.location).to include("error")
        end

        it "should NOT contain code" do
          expect(response.location).to_not include("code")
        end
      end
    end
  end

  describe "#destroy" do
    context "with existent authorization" do
      it "removes the authorization" do
        auth_with_read = FactoryGirl.create(:auth_with_read, o_auth_application: client)
        delete api_openid_connect_authorization_path(auth_with_read.id)
        expect(Api::OpenidConnect::Authorization.find_by(id: auth_with_read.id)).to be_nil
      end
    end

    context "with non-existent authorization" do
      it "raises an error" do
        delete api_openid_connect_authorization_path(123_456_789)
        expect(response).to redirect_to(api_openid_connect_user_applications_url)
        expect(flash[:error]).to eq("The attempt to revoke the authorization with ID 123456789 failed")
      end
    end
  end
end
