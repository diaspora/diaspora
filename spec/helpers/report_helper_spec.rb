require "spec_helper"

describe ReportHelper, type: :helper do
  before do
    @user = bob
    @post = @user.post(:status_message, text: "hello", to: @user.aspects.first.id)
    @comment = @user.comment!(@post, "welcome")
  end

  describe "#get_reported_guid" do
    it "returns user guid from post" do
      expect(helper.get_reported_guid(@post, "post")) == @user.guid
    end
    it "returns user guid from comment" do
      expect(helper.get_reported_guid(@comment, "comment")) == @user.guid
    end
  end

  describe "#report_content" do
    it "contains a link to the post" do
      expect(helper.report_content(@post, "post")).to include %(href="#{post_path(@post)}")
    end
    it "contains an anchor to the comment" do
      expect(helper.report_content(@comment, "comment")).to include %(href="#{post_path(@post, anchor: @comment.guid)}")
    end
  end
end
