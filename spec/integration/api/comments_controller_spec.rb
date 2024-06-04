# frozen_string_literal: true

require_relative "api_spec_helper"

describe Api::V1::CommentsController do
  let(:auth) {
    FactoryBot.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read public:modify private:read interactions],
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
    eve.person.profile = FactoryBot.create(:profile_with_image_url)

    @status = alice.post(
      "Post",
      status_message: {text: "This is a status message"},
      public:         true,
      to:             "all",
      type:           "Post"
    )

    @eves_post = eve.post(
      "Post",
      status_message: {text: "This is a status message"},
      public:         true,
      to:             "all",
      type:           "Post"
    )

    @comment_on_eves_post = comment_service.create(@eves_post.guid, "Comment on eve's post")

    aspect = auth_public_only.user.aspects.create(name: "first aspect")
    @private_post = auth_public_only.user.post(
      "Post",
      status_message: {text: "This is a private status message"},
      public:         false,
      to:             [aspect.id],
      type:           "Post"
    )
    @comment_on_private_post = comment_service(auth_public_only.user).create(@private_post.guid, "Private comment")
  end

  describe "#create" do
    context "valid post ID" do
      it "succeeds in adding a comment" do
        comment_text = "This is a comment"
        post(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {body: comment_text, access_token: access_token}
        )
        expect(response.status).to eq(201)
        comment = response_body(response)
        confirm_comment_format(comment, auth.user, comment_text)
      end

      it "creates with mentions" do
        comment_text = "hello @{#{alice.diaspora_handle}} from Bob!"
        post(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {body: comment_text, access_token: access_token}
        )
        expect(response.status).to eq(201)
        comment = response_body(response)
        confirm_comment_format(comment, auth.user, comment_text)
        expect(comment["mentioned_people"].size).to eq(1)
        expect(comment["mentioned_people"][0]).to include("diaspora_id" => alice.diaspora_handle)
      end
    end

    context "wrong post id" do
      it "fails at adding a comment" do
        post(
          api_v1_post_comments_path(post_id: "999_999_999"),
          params: {body: "text", access_token: access_token}
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end
    end

    context "lack of permissions" do
      it "fails at adding a comment" do
        alice.blocks.create(person: auth.user.person)
        post(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {body: "That shouldn't be there because I am ignored by this user", access_token: access_token}
        )
        expect(response.status).to eq(422)
      end
    end

    context "with improper credentials" do
      it "fails on private post without private:read" do
        post(
          api_v1_post_comments_path(post_id: @private_post.guid),
          params: {body: "comment text", access_token: access_token_public_only}
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end

      it "fails without interactions scope" do
        post(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {body: "comment text", access_token: access_token_minimum_scopes}
        )
        expect(response.status).to eq(403)
      end

      it "fails without valid token" do
        post(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {body: "comment text", access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#index" do
    before do
      @comment_text1 = "This is a comment"
      @comment_text2 = "This is a comment 2"
      @comment1 = comment_service.create(@status.guid, @comment_text1)
      comment_service.create(@status.guid, @comment_text2)
    end

    context "valid post ID" do
      it "retrieves related comments" do
        get(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {access_token: access_token_minimum_scopes}
        )
        expect(response.status).to eq(200)
        comments = response_body(response)
        expect(comments.length).to eq(2)
        confirm_comment_format(comments[0], auth.user, @comment_text1)
        confirm_comment_format(comments[1], auth.user, @comment_text2)
        expect(comments).to all(include("reported" => false))

        expect_to_match_json_schema(comments.to_json, "#/definitions/comments")
      end

      it "retrieves own like state" do
        like_service.create_for_comment(@comment1.id)

        get(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        comments = response_body(response)
        expect(comments[0]["interactions"]["liked"]).to eq(true)
        expect(comments[0]["interactions"]["likes_count"]).to eq(1)
        expect(comments[1]["interactions"]["liked"]).to eq(false)
        expect(comments[1]["interactions"]["likes_count"]).to eq(0)

        expect_to_match_json_schema(comments.to_json, "#/definitions/comments")
      end

      it "returns reported status of a comment" do
        auth_minimum_scopes.user.reports.create!(item: @comment1, text: "Meh!")
        get(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {access_token: access_token_minimum_scopes}
        )
        comments = response_body(response)
        expect(comments[0]["reported"]).to eq(true)
        expect(comments[1]["reported"]).to eq(false)
      end
    end

    context "wrong post id" do
      it "fails at retrieving comments" do
        get(
          api_v1_post_comments_path(post_id: "999_999_999"),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end
    end

    context "improper credentials" do
      it "fails on private post without private:read" do
        get(
          api_v1_post_comments_path(post_id: @private_post.guid),
          params: {access_token: access_token_public_only}
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end

      it "fails without valid token" do
        get(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#delete" do
    before do
      comment = comment_service.create(@status.guid, "This is a comment")
      @comment_guid = comment.guid
    end

    context "valid comment ID" do
      it "succeeds in deleting comment" do
        delete(
          api_v1_post_comment_path(
            post_id: @status.guid,
            id:      @comment_guid
          ),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(204)
        expect { comment_service.find!(@comment_guid) }.to(
          raise_error(ActiveRecord::RecordNotFound)
        )
      end
    end

    context "invalid Post ID" do
      it "fails at deleting comment" do
        delete(
          api_v1_post_comment_path(
            post_id: "999_999_999",
            id:      @comment_guid
          ),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end
    end

    context "invalid comment ID" do
      it "fails at deleting comment" do
        delete(
          api_v1_post_comment_path(
            post_id: @status.guid,
            id:      "1_234_567"
          ),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
      end
    end

    context "mismatched post-to-comment ID" do
      it "fails at deleting comment" do
        delete(
          api_v1_post_comment_path(
            post_id: @status.guid,
            id:      @comment_on_eves_post.guid
          ),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Comment not found for the given post")
      end
    end

    context "insufficient permissions" do
      it "fails at deleting other user's comment on other user's post" do
        alices_comment = comment_service(alice).create(@status.guid, "Alice's comment")
        delete(
          api_v1_post_comment_path(
            post_id: @status.guid,
            id:      alices_comment.guid
          ),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 403, "User not allowed to delete the comment")
      end
    end

    context "improper credentials" do
      it "fails at deleting your comment on post without private:read token" do
        delete(
          api_v1_post_comment_path(
            post_id: @private_post.guid,
            id:      @comment_on_private_post.guid
          ),
          params: {access_token: access_token_public_only}
        )
        expect(response.status).to eq(404)
      end

      it "fails without valid token" do
        get(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#report" do
    before do
      comment = comment_service.create(@status.guid, "This is a comment")
      @comment_guid = comment.guid
    end

    context "valid comment ID" do
      it "succeeds in reporting comment" do
        post(
          api_v1_post_comment_report_path(
            post_id:    @status.guid,
            comment_id: @comment_guid
          ),
          params: {
            reason:       "bad comment",
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
        report = Report.first
        expect(report.item_type).to eq("Comment")
        expect(report.text).to eq("bad comment")
      end
    end

    context "invalid comment ID" do
      it "fails at reporting comment" do
        post(
          api_v1_post_comment_report_path(
            post_id:    @status.guid,
            comment_id: "1_234_567"
          ),
          params: {
            reason:       "bad comment",
            access_token: access_token
          }
        )
        confirm_api_error(response, 404, "Comment not found for the given post")
      end
    end

    context "invalid Post ID" do
      it "fails at reporting comment" do
        post(
          api_v1_post_comment_report_path(
            post_id:    "999_999_999",
            comment_id: @comment_guid
          ),
          params: {
            reason:       "bad comment",
            access_token: access_token
          }
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end
    end

    context "invalid Post ID" do
      it "fails at reporting comment" do
        post(
          api_v1_post_comment_report_path(
            post_id:    "999_999_999",
            comment_id: @comment_guid
          ),
          params: {
            reason:       "bad comment",
            access_token: access_token
          }
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end
    end

    context "mismatched post-to-comment ID" do
      it "fails at reporting comment" do
        post(
          api_v1_post_comment_report_path(
            post_id:    @status.guid,
            comment_id: @comment_on_eves_post.guid
          ),
          params: {
            reason:       "bad comment",
            access_token: access_token
          }
        )
        confirm_api_error(response, 404, "Comment not found for the given post")
      end
    end

    context "already reported" do
      it "fails at reporting comment" do
        post(
          api_v1_post_comment_report_path(
            post_id:    @status.guid,
            comment_id: @comment_guid
          ),
          params: {
            reason:       "bad comment",
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)

        post(
          api_v1_post_comment_report_path(
            post_id:    @status.guid,
            comment_id: @comment_guid
          ),
          params: {
            reason:       "bad comment",
            access_token: access_token
          }
        )
        confirm_api_error(response, 409, "This item already has been reported by this user")
      end
    end

    context "improper credentials" do
      it "fails on private post without private:read" do
        post(
          api_v1_post_comment_report_path(
            post_id:    @private_post.guid,
            comment_id: @comment_on_private_post.guid
          ),
          params: {
            reason:       "bad comment",
            access_token: access_token_public_only
          }
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end

      it "fails without valid token" do
        get(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  def comment_service(user=auth.user)
    CommentService.new(user)
  end

  def like_service(user=auth.user)
    LikeService.new(user)
  end

  def response_body(response)
    JSON.parse(response.body)
  end

  private

  # rubocop:disable Metrics/AbcSize
  def confirm_comment_format(comment, user, comment_text)
    expect(comment.has_key?("guid")).to be_truthy
    expect(comment.has_key?("created_at")).to be_truthy
    expect(comment["body"]).to eq(comment_text)
    author = comment["author"]
    expect(author["guid"]).to eq(user.guid)
    expect(author["diaspora_id"]).to eq(user.diaspora_handle)
    expect(author["name"]).to eq(user.name)
    expect(author["avatar"]).to eq(user.profile.image_url(size: :thumb_medium))
  end
  # rubocop:enable Metrics/AbcSize
end
