# frozen_string_literal: true

require "spec_helper"

describe Api::V0::PostsController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }

  before do
    @status = auth.user.post(:status_message, text: "This is a status message", public: true, to: "all")
  end

  describe "#create" do
    context "valid post ID" do
      it "succeeds" do
        post api_v0_post_comments_path(post_id: @status.id), text: "This is a comment", access_token: access_token
        expect(JSON.parse(response.body)["text"]).to eq("This is a comment")
      end
    end

    context "comment too long" do
      before do
        post(
          api_v0_post_comments_path(post_id: @status.id),
          text: "This is a long comment" * 99_999, access_token: access_token
        )
      end

      it "fails with appropriate error message" do
        expect(response.body).to eq("Comment creation has failed")
      end
    end
  end

  describe "#delete" do
    context "valid comment ID" do
      before do
        post api_v0_post_comments_path(post_id: @status.id), text: "This is a comment", access_token: access_token
      end

      it "succeeds" do
        first_comment_id = JSON.parse(response.body)["id"]
        delete api_v0_post_comment_path(id: first_comment_id), access_token: access_token
        expect(response.body).to eq("Comment " + first_comment_id.to_s + " has been successfully deleted")
      end
    end

    context "invalid comment ID" do
      before do
        post api_v0_post_comments_path(post_id: @status.id), text: "This is a comment", access_token: access_token
      end

      it "fails to delete" do
        delete api_v0_post_comment_path(id: 1_234_567), access_token: access_token
        expect(response.body).to eq("Post or comment not found")
      end
    end
  end
end
