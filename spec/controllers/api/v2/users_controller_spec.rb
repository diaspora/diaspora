require 'spec_helper'

# TODO: Confirm that the cache-control header in the response is private as according to RFC 6750
# TODO: Check for WWW-Authenticate response header field as according to RFC 6750
describe Api::V2::UsersController, type: :request do
  describe "#show" do
    let!(:application) { bob.o_auth_applications.create!(client_id: 1, client_secret: "secret") }
    let!(:token) { application.tokens.create!.bearer_token.to_s }

    context "when valid" do
      it "shows the user's info" do
        get "/api/v2/user/?access_token=" + token
        jsonBody = JSON.parse(response.body)
        expect(jsonBody["username"]).to eq(bob.username)
        expect(jsonBody["email"]).to eq(bob.email)
      end
    end
  end
end
