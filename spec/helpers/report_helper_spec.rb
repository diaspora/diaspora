# frozen_string_literal: true

describe ReportHelper, type: :helper do
  before do
    @user = bob
    @post = @user.post(:status_message, text: "hello", to: @user.aspects.first.id)
    @comment = @user.comment!(@post, "welcome")

    @post_report = @user.reports.create(
      item_id: @post.id, item_type: "Post",
      text: "offensive content"
    )
    @comment_report = @user.reports.create(
      item_id: @comment.id, item_type: "Comment",
      text: "offensive content"
    )
  end

  describe "#report_content" do
    it "contains a link to the post" do
      expect(helper.report_content(@post_report))
        .to include %(href="#{post_path(@post)}")
    end
    it "contains an anchor to the comment" do
      expect(helper.report_content(@comment_report))
        .to include %(href="#{post_path(@post, anchor: @comment.guid)}")
    end
  end

  describe "#unreviewed_reports_count" do
    it "returns the number of unreviewed reports" do
      @comment_report.mark_as_reviewed
      expect(helper.unreviewed_reports_count).to be(1)
    end
  end
end
