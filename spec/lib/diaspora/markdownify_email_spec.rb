require 'spec_helper'

describe Diaspora::Markdownify::Email do
  describe '#preprocess' do
    before do
      @html = Diaspora::Markdownify::Email.new
    end

    it 'should autolink a hashtag' do
      markdownified = @html.preprocess("#tag")
      expect(markdownified).to eq("[#tag](http://localhost:9887/tags/tag)")
    end

    it 'should autolink multiple hashtags' do
      markdownified = @html.preprocess("There are #two #Tags")
      expect(markdownified).to eq("There are [#two](http://localhost:9887/tags/two) [#Tags](http://localhost:9887/tags/tags)")
    end

    it 'should not autolink headers' do
      markdownified = @html.preprocess("# header")
      expect(markdownified).to eq("# header")
    end
  end

  describe "Markdown rendering" do
    before do
      @markdown = Redcarpet::Markdown.new(Diaspora::Markdownify::Email)
      @sample_text = "# Header\n\n#messages containing #hashtags should render properly"
    end

    it 'should render the message' do
      rendered = @markdown.render(@sample_text).strip
      expect(rendered).to eq("<h1>Header</h1>\n\n<p><a href=\"http://localhost:9887/tags/messages\">#messages</a> containing <a href=\"http://localhost:9887/tags/hashtags\">#hashtags</a> should render properly</p>")
    end
  end
end