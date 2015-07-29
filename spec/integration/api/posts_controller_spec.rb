require "spec_helper"

describe Api::V0::PostsController do
  # TODO: Replace with factory
  let!(:client) do
    Api::OpenidConnect::OAuthApplication.create!(
      client_name: "Diaspora Test Client", redirect_uris: ["http://localhost:3000/"])
  end
  let(:auth_with_read) do
    auth = Api::OpenidConnect::Authorization.create!(o_auth_application: client, user: alice)
    auth.scopes << [Api::OpenidConnect::Scope.find_or_create_by(name: "read")]
    auth
  end
  let!(:access_token_with_read) { auth_with_read.create_access_token.to_s }
  let(:auth_with_read_and_write) do
    auth = Api::OpenidConnect::Authorization.create!(o_auth_application: client, user: bob)
    auth.scopes << [Api::OpenidConnect::Scope.find_or_create_by(name: "read"),
                    Api::OpenidConnect::Scope.find_or_create_by(name: "write")]
    auth
  end
  let!(:access_token_with_read_and_write) { auth_with_read_and_write.create_access_token.to_s }

  let!(:post_service_double) { double("post_service") }
  before do
    allow(PostService).to receive(:new).and_return(post_service_double)
  end

  describe "#show" do
    before do
      expect(post_service_double).to receive(:mark_user_notifications)
      allow(post_service_double).to receive(:present_json)
    end

    it "shows attempts to show the info" do
      @status = alice.post(:status_message, text: "hello", public: true, to: "all")
      get api_v0_post_path(@status.id), access_token: access_token_with_read
    end
  end

  describe "#destroy" do
    context "when given read-write access token" do
      it "attempts to destroy the post" do
        expect(post_service_double).to receive(:retract_post)
        @status = bob.post(:status_message, text: "hello", public: true, to: "all")
        delete api_v0_post_path(@status.id), access_token: access_token_with_read_and_write
      end
    end

    context "when given read only access token" do
      before do
        @status = alice.post(:status_message, text: "hello", public: true, to: "all")
        delete api_v0_post_path(@status.id), access_token: access_token_with_read
      end

      it "doesn't delete the post" do
        json_body = JSON.parse(response.body)
        expect(json_body["error"]).to eq("insufficient_scope")
      end
    end
  end
end
