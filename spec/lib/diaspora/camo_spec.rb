# frozen_string_literal: true

#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Diaspora::Camo do
  before do
    AppConfig.privacy.camo.root = 'http://localhost:3000/camo/'
    AppConfig.privacy.camo.key = 'kittenpower'

    @raw_image_url = 'http://example.com/kitten.jpg'
    @camo_image_url = AppConfig.privacy.camo.root + '5bc5b9d7ebd202841ab0667c4fc8d4304278f902/687474703a2f2f6578616d706c652e636f6d2f6b697474656e2e6a7067'
  end

  describe '#image_url' do
    it 'should not rewrite local URLs' do
      local_image = AppConfig.environment.url + 'kitten.jpg'
      expect(Diaspora::Camo.image_url(local_image)).to eq(local_image)
    end

    it 'should not rewrite relative URLs' do
      relative_image = '/kitten.jpg'
      expect(Diaspora::Camo.image_url(relative_image)).to eq(relative_image)
    end

    it 'should not rewrite already camo-fied URLs' do
      camo_image = AppConfig.privacy.camo.root + '1234/56789abcd'
      expect(Diaspora::Camo.image_url(camo_image)).to eq(camo_image)
    end

    it 'should rewrite external URLs' do
      expect(Diaspora::Camo.image_url(@raw_image_url)).to eq(@camo_image_url)
    end

    context "URL encoding" do
      let(:camo_image_url) {
        AppConfig.privacy.camo.root +
          "bbafe590034b976852f9a46dbcc7709e1a8e7dfb/68747470733a2f2f6578616d706c652e636f6d2f2543332541312543332541392" \
          "543332542333f666f6f3d254333254134254333254243254333254236266261723d61254343253830"
      }

      it "should encode URLs before sending to camo" do
        expect(Diaspora::Camo.image_url("https://example.com/áéó?foo=äüö&bar=à")).to eq(camo_image_url)
      end

      it "should not double encode already encoded URLs" do
        expect(Diaspora::Camo.image_url("https://example.com/%C3%A1%C3%A9%C3%B3?foo=%C3%A4%C3%BC%C3%B6&bar=a%CC%80"))
          .to eq(camo_image_url)
      end

      it "ignores invalid urls" do
        expect(Diaspora::Camo.image_url("https://")).to eq("https://")
      end
    end
  end

  describe '#from_markdown' do
    it 'should rewrite plain markdown images' do
      expect(Diaspora::Camo.from_markdown("![](#{@raw_image_url})")).to include(@camo_image_url)
    end

    it 'should rewrite markdown images with alt texts' do
      expect(Diaspora::Camo.from_markdown("![a kitten](#{@raw_image_url})")).to include(@camo_image_url)
    end

    it 'should rewrite markdown images with title texts' do
      expect(Diaspora::Camo.from_markdown("![](#{@raw_image_url}) \"title\"")).to include(@camo_image_url)
    end

    it 'should rewrite URLs inside <img/> tags' do
      image_tag = '<img src="' + @raw_image_url +  '" />'
      expect(Diaspora::Camo.from_markdown(image_tag)).to include(@camo_image_url)
    end
  end
end
