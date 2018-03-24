# frozen_string_literal: true

describe MetaDataHelper, type: :helper do
  describe "#meta_tag" do
    it "returns an empty string if passed an empty hash" do
      expect(meta_tag({})).to eq("")
    end

    it "returns a meta tag with the passed attributes" do
      attributes = {name: "test", content: "foo"}
      expect(meta_tag(attributes)).to eq('<meta name="test" content="foo" />')
    end

    it "returns a list of the same meta type if the value for :content in the passed attribute is an array" do
      attributes = {property: "og:tag", content: %w(tag_1 tag_2)}
      expect(meta_tag(attributes)).to eq(
        %(<meta property="og:tag" content="tag_1" />\n) +
        %(<meta property="og:tag" content="tag_2" />)
      )
    end
  end

  describe '#metas_tags' do
    before do
      @attributes = {
        description: {name: "description", content: "i am a test"},
        og_website:  {property: "og:website", content: "http://www.test2.com"}
      }
      default_attributes = {
        description: {name: "description", content: "default description"},
        og_url:      {property: "og:url",  content: "http://www.defaulturl.com"}
      }
      allow(helper).to receive(:general_metas).and_return(default_attributes)
    end

    it "returns the default meta datas if passed nothing" do
      metas_html = %(<meta name="description" content="default description" />\n) +
                   %(<meta property="og:url" content="http://www.defaulturl.com" />)
      expect(helper.metas_tags).to eq(metas_html)
    end

    it "combines by default the general meta datas with the passed attributes" do
      metas_html = %(<meta name="description" content="i am a test" />\n) +
                   %(<meta property="og:url" content="http://www.defaulturl.com" />\n) +
                   %(<meta property="og:website" content="http://www.test2.com" />)
      expect(helper.metas_tags(@attributes)).to eq(metas_html)
    end

    it "does not combines the general meta datas with the passed attributes if option is disabled" do
      default_metas_html = %(<meta name="description" content="default description" />\n) +
                           %(<meta property="og:url" content="http://www.defaulturl.com" />)
      expect(helper.metas_tags(@attributes, false)).not_to include(default_metas_html)
    end
  end
end
