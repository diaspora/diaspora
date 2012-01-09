require 'spec_helper'

describe Diaspora::Markdownify::HTML do
  describe '#autolink' do
    before do
      @html = Diaspora::Markdownify::HTML.new
    end

    it 'makes all of the links open in a new tab' do
      markdownified = @html.autolink("http://joindiaspora.com", nil)
      doc = Nokogiri.parse(markdownified)

      link = doc.css("a")

      link.attr("target").value.should == "_blank"
    end

    it 'shortens most URLs to just the domain with an ellipsis' do
      markup = @html.autolink('https://joindiaspora.com/stream', nil)
      markup.should == %{<a href="https://joindiaspora.com/stream" target="_blank" title="https://joindiaspora.com/stream">joindiaspora.com/...</a>}

      markup = @html.autolink('http://joindiaspora.com/', nil)
      markup.should == %{<a href="http://joindiaspora.com/" target="_blank">http://joindiaspora.com/</a>}

      markup = @html.autolink('http://joindiaspora.com', nil)
      markup.should == %{<a href="http://joindiaspora.com" target="_blank">http://joindiaspora.com</a>}
    end
  end
end
