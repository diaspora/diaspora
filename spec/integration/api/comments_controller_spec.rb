# frozen_string_literal: true

require "spec_helper"

describe Api::V1::CommentsController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }

  before do
    @status = auth.user.post(
      "Post",
      status_message: {text: "This is a status message"},
      public:         true,
      to:             "all",
      type:           "Post"
    )
  end

  describe "#create" do
    context "valid post ID" do
      it "succeeds in adding a comment" do
        create_comment(@status.guid, "This is a comment")
        expect(response.status).to eq(201)
        comment = response_body(response)
        expect(comment["body"]).to eq("This is a comment")
        expect(comment_service.find!(comment["guid"])).to_not be_nil
      end
    end

    context "wrong post id" do
      it "fails at adding a comment" do
        create_comment("999_999_999", "This is a comment")
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#read" do
    before do
      create_comment(@status.guid, "This is a comment")
      create_comment(@status.guid, "This is a comment 2")
    end

    context "valid post ID" do
      it "retrieves related comments" do
        get(
          api_v1_post_comments_path(post_id: @status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        expect(response_body(response).length).to eq(2)
      end
    end

    context "wrong post id" do
      it "fails at retrieving comments" do
        get(
          api_v1_post_comments_path(post_id: "999_999_999"),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
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
      end
    end
  end

  def comment_service
    CommentService.new(auth.user)
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
end
