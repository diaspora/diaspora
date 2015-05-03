require 'spec_helper'

describe ReportHelper, :type => :helper do
  before do
    @comment = FactoryGirl.create(:comment)
    @post = @comment.post
  end

  describe "#report_content" do
    it "contains a link to the post" do
      expect(helper.report_content(@post, 'post')).to include %Q(href="#{post_path(@post)}")
    end
    it "contains an anchor to the comment" do 
      expect(helper.report_content(@comment, 'comment')).to include %Q(href="#{post_path(@post, anchor: @comment.guid)}")
    end
  end
end
