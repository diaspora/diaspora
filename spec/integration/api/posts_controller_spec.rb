# frozen_string_literal: true

require "spec_helper"

describe Api::V1::PostsController do
  let!(:auth_with_read) { FactoryGirl.create(:auth_with_read) }
  let!(:access_token_with_read) { auth_with_read.create_access_token.to_s }
  let(:auth_with_read_and_write) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token_with_read_and_write) { auth_with_read_and_write.create_access_token.to_s }

  let!(:post_service_double) { double("post_service") }
  before do
    allow(PostService).to receive(:new).and_return(post_service_double)
  end

  describe "#show" do
    before do
      expect(post_service_double).to receive(:present_api_json)
    end

    context "when mark notifications is omitted" do
      it "shows attempts to show the info and mark the user notifications" do
        expect(post_service_double).to receive(:mark_user_notifications)
        @status = auth_with_read.user.post(:status_message, text: "hello", public: true, to: "all")
        get(
          api_v1_post_path(@status.id),
          params: {access_token: access_token_with_read}
        )
      end
    end

    context "when mark notifications is false" do
      it "shows attempts to show the info" do
        @status = auth_with_read.user.post(:status_message, text: "hello", public: true, to: "all")
        get(
          api_v1_post_path(@status.id),
          params: {
            access_token:       access_token_with_read,
            mark_notifications: "false"
          }
        )
      end
    end
  end

  describe "#create" do
    context "when given read-write access token" do
      it "creates a public post" do
        post(
          api_v1_posts_path,
          params: {
            access_token:   access_token_with_read_and_write,
            status_message: {text: "Hello this is a public post!"},
            aspect_ids:     "public"
          }
        )
        expect(Post.find_by(text: "Hello this is a public post!").public).to eq(true)
      end

      it "creates a private post" do
        post(
          api_v1_posts_path,
          params: {
            access_token:   access_token_with_read_and_write,
            status_message: {text: "Hello this is a post!"},
            aspect_ids:     "1"
          }
        )
        expect(Post.find_by(text: "Hello this is a post!").public).to eq(false)
      end
    end

    context "when given read only access token" do
      before do
        post(
          api_v1_posts_path,
          params: {
            access_token:   access_token_with_read,
            status_message: {text: "Hello this is a post!"},
            aspect_ids:     "public"
          }
        )
      end

      it "doesn't create the post" do
        json_body = JSON.parse(response.body)
        expect(json_body["error"]).to eq("insufficient_scope")
      end
    end
  end

  describe "#destroy" do
    context "when given read-write access token" do
      it "attempts to destroy the post" do
        expect(post_service_double).to receive(:retract_post)
        @status = auth_with_read_and_write.user.post(:status_message, text: "hello", public: true, to: "all")
        delete(
          api_v1_post_path(@status.id),
          params: {access_token: access_token_with_read_and_write}
        )
      end
    end

    context "when given read only access token" do
      before do
        @status = auth_with_read.user.post(:status_message, text: "hello", public: true, to: "all")
        delete(
          api_v1_post_path(@status.id),
          params: {access_token: access_token_with_read}
        )
      end

      it "doesn't delete the post" do
        json_body = JSON.parse(response.body)
        expect(json_body["error"]).to eq("insufficient_scope")
      end
    end
  end
end
