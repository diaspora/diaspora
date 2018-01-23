# frozen_string_literal: true

require "spec_helper"

describe Api::V1::PostsController do
  let!(:auth_with_read) { FactoryGirl.create(:auth_with_read) }
  let!(:access_token_with_read) { auth_with_read.create_access_token.to_s }

  let(:auth_with_read_and_write) {
    FactoryGirl.create(:auth_with_read_and_write)
  }
  let!(:access_token_with_read_and_write) {
    auth_with_read_and_write.create_access_token.to_s
  }

  describe "#show" do
    before do
      bob.email = "bob@example.com"
      bob.save
    end

    context "when mark notifications is omitted" do
      it "shows attempts to show the info and mark the user notifications" do
        @status = auth_with_read.user.post(
          :status_message,
          text:   "hello @{bob Testing ; bob@example.com}",
          public: true,
          to:     "all"
        )
        get(
          api_v1_post_path(@status.id),
          params: {access_token: access_token_with_read}
        )
        expect(response.status).to eq(200)
        post = response_body(response)
        expect(post["post_type"]).to eq("StatusMessage")
        expect(post["public"]).to eq(true)
        expect(post["author"]["id"]).to eq(auth_with_read.user.person.id)
        expect(post["interactions"]["comments_count"]).to eq(0)

        mention_ids = Mention.where(
          mentions_container_id:   @status.id,
          mentions_container_type: "Post",
          person_id:               bob.person.id
        ).ids
        Notification.where(
          recipient_id: bob.person.id,
          target_type:  "Mention",
          target_id:    mention_ids,
          unread:       true
        )
        # expect(notifications.length).to eq(0)
      end
    end

    context "when mark notifications is false" do
      it "shows attempts to show the info" do
        @status = auth_with_read.user.post(
          :status_message,
          text:   "hello @{bob ; bob@example.com}",
          public: true,
          to:     "all"
        )

        get(
          api_v1_post_path(@status.id),
          params: {
            access_token:       access_token_with_read,
            mark_notifications: "false"
          }
        )
        expect(response.status).to eq(200)
        post = response_body(response)

        expect(post["post_type"]).to eq("StatusMessage")
        expect(post["public"]).to eq(true)
        expect(post["author"]["id"]).to eq(auth_with_read.user.person.id)
        expect(post["interactions"]["comments_count"]).to eq(0)

        mention_ids = Mention.where(
          mentions_container_id:   @status.id,
          mentions_container_type: "Post",
          person_id:               bob.person.id
        ).ids
        Notification.where(
          recipient_id: bob.person.id,
          target_type:  "Mention",
          target_id:    mention_ids,
          unread:       true
        )
        # expect(notifications.length).to eq(1)
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
        expect(
          Post.find_by(text: "Hello this is a public post!").public
        ).to eq(true)
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
        @status = auth_with_read_and_write.user.post(
          :status_message,
          text:   "hello",
          public: true,
          to:     "all"
        )
        delete(
          api_v1_post_path(@status.id),
          params: {access_token: access_token_with_read_and_write}
        )
        expect(response.status).to eq(204)
      end
    end

    context "when given read only access token" do
      before do
        @status = auth_with_read.user.post(
          :status_message,
          text:   "hello",
          public: true,
          to:     "all"
        )
        delete(
          api_v1_post_path(@status.id),
          params: {access_token: access_token_with_read}
        )
      end

      it "doesn't delete the post" do
        json_body = JSON.parse(response.body)
        expect(json_body["error"]).to eq("insufficient_scope")
        expect(response.status).to eq(403)
      end
    end
  end

  def response_body(response)
    JSON.parse(response.body)
  end
end
