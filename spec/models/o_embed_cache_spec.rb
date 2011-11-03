require 'spec_helper'

describe OEmbedCache do

  describe '#fix_embed_code' do

    it "appends a wmode pair to the query string of youtube urls" do
      oembed_yt = OEmbedCache.new
      oembed_yt.url = "http://www.youtube.com/watch?v=NVIkck02qao&feature="
      oembed_yt.data = {
                "html"=>"<iframe width=\"420\" height=\"315\" src=\"http://www.youtube.com/embed/uJi2rkHiNqg?fs=1&feature=oembed\" frameborder=\"0\" allowfullscreen></iframe>",
                "trusted_endpoint_url"=>"http://www.youtube.com/oembed",
                "type"=>"video" }
      oembed_yt.fix_embed_code
      oembed_yt.data['html'].should include("wmode=transparent")
    end

    it "injects a wmode param tag to soundcloud object html" do
      oembed_sc = OEmbedCache.new
      oembed_sc.url = "http://soundcloud.com/rekado/on-the-inside-its-just-as-bad"
      oembed_sc.data = {
        "html"=>"<object height=\"81\" width=\"420\">\n<param name=\"movie\" value=\"http://player.soundcloud.com/player.swf?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F23603731\"></param>\n<param name=\"allowscriptaccess\" value=\"always\"></param>\n<embed allowscriptaccess=\"always\" height=\"81\" src=\"http://player.soundcloud.com/player.swf?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F23603731\" type=\"application/x-shockwave-flash\" width=\"420\"></embed>\n</object>\n\n<span><a href=\"http://soundcloud.com/rekado/on-the-inside-its-just-as-bad\">On the inside it's just as bad</a> by <a href=\"http://soundcloud.com/rekado\">rekado</a></span>\n",
        "trusted_endpoint_url"=>"http://soundcloud.com/oembed",
        "type"=>"rich" }

      oembed_sc.fix_embed_code
      oembed_sc.data['html'].should include("param name=\"wmode\" value=\"transparent\"")
    end

    it "only processes objects that are of type 'video' or 'rich'" do
      oembed = OEmbedCache.new
      oembed.url = "http://some-provier.com/some-resource"
      oembed.data = {
        "html"=>"<p>test</p>",
        "trusted_endpoint_url"=>"http://soundcloud.com/oembed",
        "type"=>"not-rich" }
      oembed.fix_embed_code
      oembed.data['html'].should_not include("wmode")
    end

  end

end
