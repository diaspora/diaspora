# frozen_string_literal: true

require_relative "api_spec_helper"

describe Api::V1::LikesController do
  let(:auth) {
    FactoryBot.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read public:modify private:read private:modify interactions],
      user:   FactoryBot.create(:user, profile: FactoryBot.create(:profile_with_image_url))
    )
  }

  let(:auth_public_only) {
    FactoryBot.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read public:modify interactions]
    )
  }

  let(:auth_minimum_scopes) {
    FactoryBot.create(:auth_with_default_scopes)
  }

  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_public_only) { auth_public_only.create_access_token.to_s }
  let!(:access_token_minimum_scopes) { auth_minimum_scopes.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(9) }

  before do
    alice.person.profile = FactoryBot.create(:profile_with_image_url)
    bob.person.profile = FactoryBot.create(:profile_with_image_url)

    @status = auth.user.post(
      :status_message,
      text:   "This is a status message",
      public: true,
      to:     "all"
    )

    aspect = auth_public_only.user.aspects.create(name: "first aspect")
    @private_status = auth_public_only.user.post(
      "Post",
      status_message: {text: "This is a private status message"},
      public:         false,
      to:             [aspect.id],
      type:           "Post"
    )
  end

  describe "#show" do
    context "with right post id" do
      it "succeeds in getting empty likes" do
        get(
          api_v1_post_likes_path(post_id: @status.guid),
          params: {access_token: access_token_minimum_scopes}
        )
        expect(response.status).to eq(200)
        likes = response_body(response)
        expect(likes.length).to eq(0)
      end

      it "succeeds in getting post with likes" do
        like_service(bob).create_for_post(@status.guid)
        like_service(auth.user).create_for_post(@status.guid)
        like_service(alice).create_for_post(@status.guid)
        get(
          api_v1_post_likes_path(post_id: @status.guid),
          params: {access_token: access_token_minimum_scopes}
        )
        expect(response.status).to eq(200)
        likes = response_body(response)
        expect(likes.length).to eq(3)
        confirm_like_format(likes, alice)
        confirm_like_format(likes, bob)
        confirm_like_format(likes, auth.user)

        expect_to_match_json_schema(likes.to_json, "#/definitions/likes")
      end
    end

    context "with wrong post id" do
      it "fails at getting likes" do
        get(
          api_v1_post_likes_path(post_id: "badguid"),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end
    end

    context "with improper credentials" do
      context "without private:read scope in token" do
        it "fails at getting likes" do
          get(
            api_v1_post_likes_path(post_id: @private_status.guid),
            params: {access_token: access_token_public_only}
          )
          confirm_api_error(response, 422, "User is not allowed to like")
        end
      end

      it "fails without valid token" do
        get(
          api_v1_post_likes_path(post_id: @private_status.guid),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end

    context "for comments" do
      before do
        comment = comment_service.create(@status.guid, "This is a comment")
        @comment_guid = comment.guid
      end

      context "with right post and comment id" do
        it "succeeds in getting empty likes" do
          get(
            api_v1_post_comment_likes_path(post_id: @status.guid, comment_id: @comment_guid),
            params: {access_token: access_token_minimum_scopes}
          )
          expect(response.status).to eq(200)
          likes = response_body(response)
          expect(likes.length).to eq(0)
        end

        it "succeeds in getting comment likes" do
          like_service(bob).create_for_comment(@comment_guid)
          like_service(auth.user).create_for_comment(@comment_guid)
          like_service(alice).create_for_comment(@comment_guid)
          get(
            api_v1_post_comment_likes_path(post_id: @status.guid, comment_id: @comment_guid),
            params: {access_token: access_token_minimum_scopes}
          )
          expect(response.status).to eq(200)
          likes = response_body(response)
          expect(likes.length).to eq(3)
          confirm_like_format(likes, alice)
          confirm_like_format(likes, bob)
          confirm_like_format(likes, auth.user)

          expect_to_match_json_schema(likes.to_json, "#/definitions/likes")
        end
      end

      context "with wrong post id" do
        it "fails at getting likes" do
          get(
            api_v1_post_comment_likes_path(post_id: "badguid", comment_id: @comment_guid),
            params: {access_token: access_token}
          )
          confirm_api_error(response, 404, "Post with provided guid could not be found")
        end
      end

      context "with wrong comment id" do
        it "fails at getting likes" do
          get(
            api_v1_post_comment_likes_path(post_id: @status.guid, comment_id: "badguid"),
            params: {access_token: access_token}
          )
          confirm_api_error(response, 404, "Comment not found for the given post")
        end
      end

      context "with improper credentials" do
        before do
          comment = comment_service(auth_public_only.user).create(@private_status.guid, "This is a comment")
          @comment_guid = comment.guid
        end

        context "without private:read scope in token" do
          it "fails at getting likes" do
            get(
              api_v1_post_comment_likes_path(post_id: @private_status.guid, comment_id: @comment_guid),
              params: {access_token: access_token_public_only}
            )
            confirm_api_error(response, 422, "User is not allowed to like")
          end
        end

        it "fails without valid token" do
          get(
            api_v1_post_comment_likes_path(post_id: @private_status.guid, comment_id: @comment_guid),
            params: {access_token: invalid_token}
          )
          expect(response.status).to eq(401)
        end
      end
    end
  end

  describe "#create" do
    context "with right post id" do
      it "succeeds in liking post" do
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
        confirm_api_error(response, 409, "Like already exists")

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
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end
    end

    context "with improper credentials" do
      it "fails in liking private post without private:read" do
        post(
          api_v1_post_likes_path(post_id: @private_status.guid),
          params: {access_token: access_token_public_only}
        )
        expect(response.status).to eq(422)
      end

      it "fails in liking post without interactions" do
        post(
          api_v1_post_likes_path(post_id: @private_status.guid),
          params: {access_token: access_token_minimum_scopes}
        )
        expect(response.status).to eq(403)
      end

      it "fails without valid token" do
        get(
          api_v1_post_likes_path(post_id: @private_status.guid),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end

    context "for comments" do
      before do
        comment = comment_service.create(@status.guid, "This is a comment")
        @comment_guid = comment.guid
      end

      context "with right post and comment id" do
        it "succeeds in liking comment" do
          post(
            api_v1_post_comment_likes_path(post_id: @status.guid, comment_id: @comment_guid),
            params: {access_token: access_token}
          )
          expect(response.status).to eq(204)
          likes = like_service.find_for_comment(@comment_guid)
          expect(likes.length).to eq(1)
          expect(likes[0].author.id).to eq(auth.user.person.id)
        end

        it "fails in liking already liked comment" do
          post(
            api_v1_post_comment_likes_path(post_id: @status.guid, comment_id: @comment_guid),
            params: {access_token: access_token}
          )
          expect(response.status).to eq(204)

          post(
            api_v1_post_comment_likes_path(post_id: @status.guid, comment_id: @comment_guid),
            params: {access_token: access_token}
          )
          confirm_api_error(response, 409, "Like already exists")

          likes = like_service.find_for_comment(@comment_guid)
          expect(likes.length).to eq(1)
          expect(likes[0].author.id).to eq(auth.user.person.id)
        end
      end

      context "with wrong post id" do
        it "fails at liking comment" do
          post(
            api_v1_post_comment_likes_path(post_id: 99_999_999, comment_id: @comment_guid),
            params: {access_token: access_token}
          )
          confirm_api_error(response, 404, "Post with provided guid could not be found")
        end
      end

      context "with wrong comment id" do
        it "fails at liking comment" do
          post(
            api_v1_post_comment_likes_path(post_id: @status.guid, comment_id: 99_999_999),
            params: {access_token: access_token}
          )
          confirm_api_error(response, 404, "Comment not found for the given post")
        end
      end

      context "with improper credentials" do
        before do
          comment = comment_service(auth_public_only.user).create(@private_status.guid, "This is a comment")
          @comment_guid = comment.guid
        end

        it "fails in liking private comment without private:read" do
          post(
            api_v1_post_comment_likes_path(post_id: @private_status.guid, comment_id: @comment_guid),
            params: {access_token: access_token_public_only}
          )
          expect(response.status).to eq(422)
        end

        it "fails in liking post without interactions" do
          post(
            api_v1_post_comment_likes_path(post_id: @private_status.guid, comment_id: @comment_guid),
            params: {access_token: access_token_minimum_scopes}
          )
          expect(response.status).to eq(403)
        end

        it "fails without valid token" do
          get(
            api_v1_post_comment_likes_path(post_id: @private_status.guid, comment_id: @comment_guid),
            params: {access_token: invalid_token}
          )
          expect(response.status).to eq(401)
        end
      end
    end
  end

  describe "#destroy" do
    before do
      like_service.create_for_post(@status.guid)
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
        confirm_api_error(response, 410, "Like doesn’t exist")

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
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end
    end

    context "with improper credentials" do
      it "fails at unliking private post without private:read" do
        like_service(auth_public_only.user).create_for_post(@private_status.guid)
        delete(
          api_v1_post_likes_path(post_id: @private_status.guid),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end

      it "fails in unliking post without interactions" do
        like_service(auth_minimum_scopes.user).create_for_post(@status.guid)
        delete(
          api_v1_post_likes_path(post_id: @status.guid),
          params: {access_token: access_token_minimum_scopes}
        )
        expect(response.status).to eq(403)
      end

      it "fails without valid token" do
        get(
          api_v1_post_likes_path(post_id: @private_status.guid),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end

    context "for comments" do
      before do
        comment = comment_service.create(@status.guid, "This is a comment")
        @comment_guid = comment.guid
        like_service.create_for_comment(@comment_guid)
      end

      context "with right post and comment id" do
        it "succeeds at unliking comment" do
          delete(
            api_v1_post_comment_likes_path(post_id: @status.guid, comment_id: @comment_guid),
            params: {access_token: access_token}
          )
          expect(response.status).to eq(204)
          likes = like_service.find_for_comment(@comment_guid)
          expect(likes.length).to eq(0)
        end

        it "fails at unliking comment user didn't like" do
          delete(
            api_v1_post_comment_likes_path(post_id: @status.guid, comment_id: @comment_guid),
            params: {access_token: access_token}
          )
          expect(response.status).to eq(204)

          delete(
            api_v1_post_comment_likes_path(post_id: @status.guid, comment_id: @comment_guid),
            params: {access_token: access_token}
          )
          confirm_api_error(response, 410, "Like doesn’t exist")

          likes = like_service.find_for_comment(@comment_guid)
          expect(likes.length).to eq(0)
        end
      end

      context "with wrong post id" do
        it "fails at unliking comment" do
          delete(
            api_v1_post_comment_likes_path(post_id: 99_999_999, comment_id: @comment_guid),
            params: {access_token: access_token}
          )
          confirm_api_error(response, 404, "Post with provided guid could not be found")
        end
      end

      context "with wrong comment id" do
        it "fails at unliking comment" do
          delete(
            api_v1_post_comment_likes_path(post_id: @status.guid, comment_id: 99_999_999),
            params: {access_token: access_token}
          )
          confirm_api_error(response, 404, "Comment not found for the given post")
        end
      end

      context "with improper credentials" do
        before do
          comment = comment_service(auth_public_only.user).create(@private_status.guid, "This is a comment")
          @comment_guid = comment.guid
        end

        it "fails at unliking private post without private:read" do
          like_service(auth_public_only.user).create_for_post(@private_status.guid)
          delete(
            api_v1_post_comment_likes_path(post_id: @private_status.guid, comment_id: @comment_guid),
            params: {access_token: access_token}
          )
          confirm_api_error(response, 404, "Post with provided guid could not be found")
        end

        it "fails in unliking post without interactions" do
          like_service(auth_minimum_scopes.user).create_for_post(@status.guid)
          delete(
            api_v1_post_comment_likes_path(post_id: @private_status.guid, comment_id: @comment_guid),
            params: {access_token: access_token_minimum_scopes}
          )
          expect(response.status).to eq(403)
        end

        it "fails without valid token" do
          get(
            api_v1_post_comment_likes_path(post_id: @private_status.guid, comment_id: @comment_guid),
            params: {access_token: invalid_token}
          )
          expect(response.status).to eq(401)
        end
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
    expect(author["avatar"]).to eq(user.profile.image_url(size: :thumb_medium))
  end
  # rubocop:enable Metrics/AbcSize

  def like_service(user=auth.user)
    LikeService.new(user)
  end

  def comment_service(user=auth.user)
    CommentService.new(user)
  end

  def response_body(response)
    JSON.parse(response.body)
  end
end
