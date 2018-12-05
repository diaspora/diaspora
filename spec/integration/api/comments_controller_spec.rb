# frozen_string_literal: true

require "spec_helper"

describe Api::V1::CommentsController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }

  before do
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
  end

  describe "#create" do
    context "valid post ID" do
      it "succeeds in adding a comment" do
        comment_text = "This is a comment"
        create_comment(@status.guid, comment_text)
        expect(response.status).to eq(201)
        comment = response_body(response)
        confirm_comment_format(comment, auth.user, comment_text)
      end
    end

    context "wrong post id" do
      it "fails at adding a comment" do
        create_comment("999_999_999", "This is a comment")
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
      end
    end

    context "lack of permissions" do
      it "fails at adding a comment" do
        alice.blocks.create(person: auth.user.person)
        create_comment(@status.guid, "That shouldn't be there because I am ignored by this user")
        expect(response.status).to eq(422)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.comments.not_allowed"))
      end
    end
  end

  describe "#read" do
    before do
      @comment_text1 = "This is a comment"
      @comment_text2 = "This is a comment 2"
      create_comment(@status.guid, @comment_text1)
      create_comment(@status.guid, @comment_text2)
    end

    context "valid post ID" do
      it "retrieves related comments" do
        get(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        comments = response_body_data(response)
        expect(comments.length).to eq(2)
        confirm_comment_format(comments[0], auth.user, @comment_text1)
        confirm_comment_format(comments[1], auth.user, @comment_text2)
      end
    end

    context "wrong post id" do
      it "fails at retrieving comments" do
        get(
          api_v1_post_comments_path(post_id: "999_999_999"),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
      end
    end
  end

  describe "#delete" do
    before do
      create_comment(@status.guid, "This is a comment")
      @comment_guid = response_body(response)["guid"]
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
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
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
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.comments.not_found"))
      end
    end

    context "insufficient permissions (not your comment and not owner)" do
      it "fails at deleting comment" do
        alices_comment = comment_service(alice).create(@status.guid, "Alice's comment")
        delete(
          api_v1_post_comment_path(
            post_id: @status.guid,
            id:      alices_comment.guid
          ),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(403)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.comments.no_delete"))
      end
    end
  end

  describe "#report" do
    before do
      create_comment(@status.guid, "This is a comment")
      @comment_guid = response_body(response)["guid"]
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
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.comments.not_found"))
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
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
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
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.comments.not_found"))
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
        expect(response.status).to eq(409)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.comments.duplicate_report"))
      end
    end
  end

  def comment_service(user=auth.user)
    CommentService.new(user)
  end

  def create_comment(post_guid, text)
    post(
      api_v1_post_comments_path(post_id: post_guid),
      params: {body: text, access_token: access_token}
    )
  end

  def response_body(response)
    JSON.parse(response.body)
  end

  def response_body_data(response)
    JSON.parse(response.body)["data"]
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
    expect(author["avatar"]).to eq(user.profile.image_url)
  end
  # rubocop:enable Metrics/AbcSize
end
