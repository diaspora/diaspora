# frozen_string_literal: true

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

  describe "#show" do
    context "with right post id" do
      it "succeeds in getting empty likes" do
        get(
          api_v1_post_likes_path(post_id: @status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        likes = response_body_data(response)
        expect(likes.length).to eq(0)
      end

      it "succeeds in getting post with likes" do
        like_service(bob).create(@status.guid)
        like_service(auth.user).create(@status.guid)
        like_service(alice).create(@status.guid)
        get(
          api_v1_post_likes_path(post_id: @status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        likes = response_body_data(response)
        expect(likes.length).to eq(3)
        confirm_like_format(likes, alice)
        confirm_like_format(likes, bob)
        confirm_like_format(likes, auth.user)
      end
    end

    context "with wrong post id" do
      it "fails at getting likes" do
        get(
          api_v1_post_likes_path(post_id: "badguid"),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
      end
    end
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

      it "fails in liking already liked post" do
        post(
          api_v1_post_likes_path(post_id: @status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(204)

        post(
          api_v1_post_likes_path(post_id: @status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(422)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.likes.like_exists"))

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
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
      end
    end
  end

  describe "#delete" do
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

      it "fails at unliking post user didn't like" do
        delete(
          api_v1_post_likes_path(post_id: @status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(204)

        delete(
          api_v1_post_likes_path(post_id: @status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.likes.no_like"))

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
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
      end
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def confirm_like_format(likes, user)
    like = likes.find {|like_element| like_element["author"]["guid"] == user.guid }
    author = like["author"]
    expect(author["diaspora_id"]).to eq(user.diaspora_handle)
    expect(author["name"]).to eq(user.name)
    expect(author["avatar"]).to eq(user.profile.image_url)
  end
  # rubocop:enable Metrics/AbcSize

  def like_service(user=auth.user)
    LikeService.new(user)
  end

  def response_body(response)
    JSON.parse(response.body)
  end

  def response_body_data(response)
    JSON.parse(response.body)["data"]
  end
end
