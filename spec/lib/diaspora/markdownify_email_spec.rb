require 'spec_helper'

describe Diaspora::Markdownify::Email do
  describe '#preprocess' do
    before do
      @html = Diaspora::Markdownify::Email.new
    end

    it 'should escape a hashtag' do
      markdownified = @html.preprocess("#tag")
      markdownified.should == "\\#tag"
    end

    it 'should escape multiple hashtags' do
      markdownified = @html.preprocess("There are #two #tags")
      markdownified.should == "There are \\#two \\#tags"
    end

    it 'should not escape headers' do
      markdownified = @html.preprocess("# header")
      markdownified.should == "# header"
    end
  end

  describe "Markdown rendering" do
    before do
      @markdown = Redcarpet::Markdown.new(Diaspora::Markdownify::Email)
      @sample_text = "# Header\n\n#messages containing #hashtags should render properly"
    end

    it 'should render the message' do
      rendered = @markdown.render(@sample_text).strip
      rendered.should == "<h1>Header</h1>\n\n<p>#messages containing #hashtags should render properly</p>"
    end
  end
end