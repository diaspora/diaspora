describe Diaspora::Taggable do
  include Rails.application.routes.url_helpers

  describe "#format_tags" do
    context "when there are no tags in the text" do
      it "returns the input text" do
        text = Diaspora::Taggable.format_tags("There are no tags.")
        expect(text).to eq("There are no tags.")
      end
    end

    context "when there is a tag in the text" do
      it "autolinks the hashtag" do
        text = Diaspora::Taggable.format_tags("There is a #hashtag.")
        expect(text).to eq("There is a <a class=\"tag\" href=\"/tags/hashtag\">#hashtag</a>.")
      end

      it "autolinks #<3" do
        text = Diaspora::Taggable.format_tags("#<3")
        expect(text).to eq("<a class=\"tag\" href=\"/tags/<3\">#&lt;3</a>")
      end
    end

    context "with multiple tags" do
      it "autolinks the hashtags" do
        text = Diaspora::Taggable.format_tags("#l #lol")
        expect(text).to eq("<a class=\"tag\" href=\"/tags/l\">#l</a> <a class=\"tag\" href=\"/tags/lol\">#lol</a>")
      end
    end
  end

  describe "#format_tags_for_mail" do
    context "when there are no tags in the text" do
      it "returns the input text" do
        text = Diaspora::Taggable.format_tags_for_mail("There are no tags.")
        expect(text).to eq("There are no tags.")
      end
    end

    context "when there is a tag in the text" do
      it "autolinks and normalizes the hashtag" do
        text = Diaspora::Taggable.format_tags_for_mail("There is a #hashTag.")
        expect(text).to eq("There is a [#hashTag](#{AppConfig.url_to(tag_path('hashtag'))}).")
      end

      it "autolinks #<3" do
        text = Diaspora::Taggable.format_tags_for_mail("#<3")
        expect(text).to eq("[#<3](#{AppConfig.url_to(tag_path('<3'))})")
      end
    end

    context "with multiple tags" do
      it "autolinks the hashtags" do
        text = Diaspora::Taggable.format_tags_for_mail("#l #lol")
        expect(text).to eq("[#l](#{AppConfig.url_to(tag_path('l'))}) [#lol](#{AppConfig.url_to(tag_path('lol'))})")
      end
    end
  end
end
