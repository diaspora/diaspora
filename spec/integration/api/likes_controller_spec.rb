# frozen_sTring_literal: true

require "spec_helper"

describe Api::V1::LikesController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }

  before do
    @status = auth.user.post(
      :status_message,
      text:   "This is a status message",
      public: true,
      to:     "all"
    )
  end

  describe "#create" do
    context "with right post id" do
      it "succeeeds in liking post" do
        post(
          api_v1_post_likes_path(post_id: @status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(204)
        likes = like_service.find_for_post(@status.guid)
        expect(likes.length).to eq(1)
        expect(likes[0].author.id).to eq(auth.user.person.id)
      end
    end

    context "with wrong post id" do
      it "fails at liking post" do
        post(
          api_v1_post_likes_path(post_id: 99_999_999),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#create" do
    before do
      post(
        api_v1_post_likes_path(post_id: @status.guid),
        params: {access_token: access_token}
      )
    end

    context "with right post id" do
      it "succeeds at unliking post" do
        delete(
          api_v1_post_likes_path(post_id: @status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(204)
        likes = like_service.find_for_post(@status.guid)
        expect(likes.length).to eq(0)
      end
    end

    context "with wrong post id" do
      it "fails at unliking post" do
        delete(
          api_v1_post_likes_path(post_id: 99_999_999),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
      end
    end
  end

  def like_service
    LikeService.new(auth.user)
  end
end
