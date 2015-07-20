require 'spec_helper'

describe Diaspora::Markdownify::HTML do
  describe '#autolink' do
    before do
      @html = Diaspora::Markdownify::HTML.new
    end

    it 'should make all of the links open in a new tab' do
      markdownified = @html.autolink("http://joindiaspora.com", nil)
      doc = Nokogiri.parse(markdownified)

      link = doc.css("a")

      expect(link.attr("target").value).to eq("_blank")
    end
  end
end