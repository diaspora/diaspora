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
      expect(metas_tags(attributes_list)).to eq(metas_html)
    end
  end
end
