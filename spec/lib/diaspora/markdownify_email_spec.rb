# frozen_string_literal: true

describe Diaspora::Markdownify::Email do
  include Rails.application.routes.url_helpers

  describe '#preprocess' do
    before do
      @html = Diaspora::Markdownify::Email.new
    end

    it 'should autolink a hashtag' do
      markdownified = @html.preprocess("#tag")
      expect(markdownified).to eq("[#tag](#{AppConfig.url_to(tag_path('tag'))})")
    end

    it 'should autolink multiple hashtags' do
      markdownified = @html.preprocess("oh #l #loL")
      expect(markdownified).to eq(
        "oh [#l](#{AppConfig.url_to(tag_path('l'))}) [#loL](#{AppConfig.url_to(tag_path('lol'))})"
      )
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
      expect(rendered).to eq(
        "<h1>Header</h1>\n\n<p><a href=\"#{AppConfig.url_to(tag_path('messages'))}\">#messages</a>\
 containing <a href=\"#{AppConfig.url_to(tag_path('hashtags'))}\">#hashtags</a> should render properly</p>"
      )
    end
  end
end
