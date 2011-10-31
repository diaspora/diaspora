require 'spec_helper'

describe Diaspora::Markdownify::HTML do
  describe '#autolink' do
    before do
      renderer_options = {
        :remote_pod_url => 'anotherpod.com',
        :localize_diaspora_urls => true,
      }
      @html = Diaspora::Markdownify::HTML.new(renderer_options)

      post = Factory(:status_message, :guid => "925951e0695300ff")
    end

    it 'should make all of the links open in a new tab' do
      markdownified = @html.autolink("http://joindiaspora.com", nil)
      doc = Nokogiri.parse(markdownified)

      link = doc.css("a")

      link.attr("target").value.should == "_blank"
    end

    it 'should transform urls of foreign pods to the local pod for post guids in postprocessing' do
      markdownified = @html.postprocess("hello, look at this: <a href='https://anotherpod.com/posts/925951e0695300ff'>https://anotherpod.com/posts/925951e0695300ff</a>. It's great!")
      url = "https://#{AppConfig[:pod_url]}/posts/925951e0695300ff"
      markdownified.should =~ /#{url}/
    end

    it 'should not transform urls of foreign pods to the local pod for post ids in postprocessing' do
      markdownified = @html.postprocess("hello, look at this: <a href='https://anotherpod.com/posts/123'>https://anotherpod.com/posts/123</a>. It's great!")
      url = "https://#{AppConfig[:pod_url]}/posts/123"
      markdownified.should_not =~ /#{url}/
    end
  end
end
