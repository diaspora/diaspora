# frozen_string_literal: true

describe Diaspora::Markdownify::HTML do
  describe "#autolink" do
    before do
      @html = Diaspora::Markdownify::HTML.new
    end

    it "should make all of the links open in a new tab" do
      markdownified = @html.autolink("http://joindiaspora.com", nil)
      doc = Nokogiri.parse(markdownified)

      link = doc.css("a")

      expect(link.attr("target").value).to eq("_blank")
    end

    it "should add noopener and noreferrer to autolinks' rel attributes" do
      markdownified = @html.autolink("http://joindiaspora.com", nil)
      doc = Nokogiri.parse(markdownified)

      link = doc.css("a")

      expect(link.attr("rel").value).to include("noopener", "noreferrer")
    end
  end
end
