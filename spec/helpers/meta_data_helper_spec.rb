require 'spec_helper'

describe MetaDataHelper, :type => :helper do

  describe '#meta_tag' do
    it "returns an empty string if passed an empty hash" do
      expect(meta_tag({})).to eq("")
    end

    it "returns a meta tag with the passed attributes" do
      attributes = {name: "test", content: "foo"}
      expect(meta_tag attributes).to eq('<meta name="test" content="foo" />')
    end

    it "returns a list of the same meta type if the value for :content in the passed attribute is an array" do
      attribute = {property: "og:tag", content: ['tag_1', 'tag_2']}
      expect(meta_tag attribute).to eq(
        "<meta property=\"og:tag\" content=\"tag_1\" />\n" +
        "<meta property=\"og:tag\" content=\"tag_2\" />")
    end
  end

  describe '#metas_tags' do
    it "returns an empty string if passed an empty array" do
      expect(metas_tags([])).to eq("")
    end

    it "returns a list of meta tags" do
      attributes_list = [
        {name: "description", content: "diaspora* is the online social world where you are in control."},
        {property: "og:url", content: "http://www.example.com"},
      ]
      metas_html = <<-EOF
<meta name="description" content="diaspora* is the online social world where you are in control." />
<meta property="og:url" content="http://www.example.com" />
      EOF
      metas_html.chop!
      expect(metas_tags(attributes_list)).to eq(metas_html)
    end
  end
end
