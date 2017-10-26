# frozen_string_literal: true

describe Diaspora::MessageRenderer do
  def message(text, opts={})
    Diaspora::MessageRenderer.new(text, opts)
  end

  describe '#title' do
    context 'when :length is passed in parameters' do
      it 'returns string of size less or equal to :length' do
        string_size = 12
        title = message("## This is a really, really, really long title\n Post content").title(length: string_size)
        expect(title.size).to be <= string_size
      end
    end

    context 'when :length is not passed in parameters' do
      context 'with a Markdown header of less than 200 characters on first line' do
        it 'returns atx style header' do
          expect(message("## My title\n Post content...").title).to eq "My title"
          expect(message("## My title ##\n Post content...").title).to eq "My title"
        end

        it 'returns setext style header' do
          expect(message("My title \n======\n Post content...").title).to eq "My title"
        end

        it 'returns header without markdown' do
          expect(message("## **[My title](http://diasporafoundation.org)**\n Post content...").title).to eq "My title (http://diasporafoundation.org)"
        end
      end

      context "without a Markdown header of less than 200 characters on first line" do
        it "truncates posts to the 70 first characters" do
          text = "Chillwave heirloom small batch semiotics, brunch cliche yr gluten-free whatever bitters selfies."
          expect(message(text).title).to eq "Chillwave heirloom small batch semiotics, brunch cliche yr gluten-f..."
        end
      end
    end
  end

  describe '#html' do
    it 'escapes the message' do
      xss = "</a> <script> alert('hey'); </script>"

      expect(message(xss).html).to_not include xss
    end

    it 'is html_safe' do
      expect(message("hey guys").html).to be_html_safe
    end

    it 'should leave HTML entities intact' do
      entities = '&amp; &szlig; &#x27; &#39; &quot;'
      expect(message(entities).html).to eq entities
    end

    it 'normalizes' do
      expect(
        message("\u202a#\u200eUSA\u202c").markdownified
      ).to eq %(<p><a class="tag" href="/tags/USA">#USA</a></p>\n)
    end

    context 'with mentions' do
      it 'makes hovercard links for mentioned people' do
        expect(
          message(
            "@{Bob; #{bob.person.diaspora_handle}}",
            mentioned_people: [bob.person]
          ).html
        ).to include 'hovercard'
      end

      it 'makes plaintext out of mentions of people not in the posts aspects' do
        expect(
          message("@{Bob; #{bob.person.diaspora_handle}}").html
        ).to_not include 'href'
      end

      context 'linking all mentions' do
        it 'makes plain links for people not in the post aspects' do
          message = message("@{Bob; #{bob.person.diaspora_handle}}", link_all_mentions: true).html
          expect(message).to_not include 'hovercard'
          expect(message).to include '/u/bob'
        end

        it "makes no hovercards if they're disabled" do
          message = message(
            "@{Bob; #{bob.person.diaspora_handle}}",
            mentioned_people: [bob.person],
            disable_hovercards: true
          ).html
          expect(message).to_not include 'hovercard'
          expect(message).to include '/u/bob'
        end
      end
    end

    context "with diaspora:// links" do
      it "replaces diaspora:// links with pod-local links" do
        target = FactoryGirl.create(:status_message)
        expect(
          message("Have a look at diaspora://#{target.diaspora_handle}/post/#{target.guid}.").html
        ).to match(/Have a look at #{AppConfig.url_to("/posts/#{target.guid}")}./)
      end

      it "doesn't touch invalid diaspora:// links" do
        text = "You can create diaspora://author/type/guid links!"
        expect(message(text).html).to match(/#{text}/)
      end

      it "ignores a diaspora:// links with a unknown guid" do
        text = "Try this: `diaspora://unknown@localhost:3000/post/thislookslikeavalidguid123456789`"
        expect(message(text).html).to match(/#{text}/)
      end

      it "ignores a diaspora:// links with an invalid entity type" do
        target = FactoryGirl.create(:status_message)
        text = "Try this: `diaspora://#{target.diaspora_handle}/posts/#{target.guid}`"
        expect(message(text).html).to match(/#{text}/)
      end
    end
  end

  describe "#markdownified" do
    describe "not doing something dumb" do
      it "strips out script tags" do
        expect(
          message("<script>alert('XSS is evil')</script>").markdownified
        ).to eq "<p>alert(&#39;XSS is evil&#39;)</p>\n"
      end

      it 'strips onClick handlers from links' do
        expect(
          message('[XSS](http://joindiaspora.com/" onClick="$\(\'a\'\).remove\(\))').markdownified
        ).to_not match(/ onClick/i)
      end
    end

    it 'does not barf if message is nil' do
      expect(message(nil).markdownified).to eq ''
    end

    it 'autolinks standard url links' do
      expect(
        message("http://joindiaspora.com/").markdownified
      ).to include 'href="http://joindiaspora.com/"'
    end

    it "normalizes" do
      {
        "\u202a#\u200eUSA\u202c" => "<p><a class=\"tag\" href=\"/tags/USA\">#USA</a></p>\n",
        "ള്‍"                    => "<p>ള്‍</p>\n"
      }.each do |input, output|
        expect(message(input).markdownified).to eq output
      end
    end

    context 'when formatting status messages' do
      it "should leave tags intact" do
        expect(
          message("I love #markdown").markdownified
        ).to match %r{<a class="tag" href="/tags/markdown">#markdown</a>}
      end

      it 'should leave multi-underscore tags intact' do
        expect(
          message("Here is a #multi_word tag").markdownified
        ).to match  %r{Here is a <a class="tag" href="/tags/multi_word">#multi_word</a> tag}

        expect(
          message("Here is a #multi_word_tag yo").markdownified
        ).to match %r{Here is a <a class="tag" href="/tags/multi_word_tag">#multi_word_tag</a> yo}
      end

      it "should leave mentions intact" do
        expect(
          message("Hey @{Bob; #{bob.diaspora_handle}}!", mentioned_people: [bob.person]).markdownified
        ).to match(/hovercard/)
      end

      it "should leave mentions intact for real diaspora handles" do
        new_person = FactoryGirl.create(:person, diaspora_handle: 'maxwell@joindiaspora.com')
        expect(
          message(
            "Hey @{maxwell@joindiaspora.com; #{new_person.diaspora_handle}}!",
            mentioned_people: [new_person]
          ).markdownified
        ).to match(/hovercard/)
      end

      it 'should process text with both a hashtag and a link' do
        expect(
          message("Test #tag?\nhttps://joindiaspora.com\n").markdownified
        ).to eq %{<p>Test <a class="tag" href="/tags/tag">#tag</a>?<br>\n<a href="https://joindiaspora.com" rel="nofollow noopener noreferrer" target="_blank">https://joindiaspora.com</a></p>\n}
      end

      it 'should process text with a header' do
        expect(message("# I love markdown").markdownified).to match "I love markdown"
      end

      it 'should leave HTML entities intact' do
        entities = '&amp; &szlig; &#x27; &#39; &quot;'
        expect(message(entities).markdownified).to eq "<p>#{entities}</p>\n"
      end

      context "with diaspora:// links" do
        it "replaces diaspora:// links with pod-local links" do
          target1 = FactoryGirl.create(:status_message)
          target2 = FactoryGirl.create(:status_message)
          text = "Have a look at [this post](diaspora://#{target1.diaspora_handle}/post/#{target1.guid}) and " \
                 "this one too diaspora://#{target2.diaspora_handle}/post/#{target2.guid}."

          rendered = message(text).markdownified

          expect(rendered).to match(%r{at <a href="#{AppConfig.url_to("/posts/#{target1.guid}")}">this post</a> and})
          expect(rendered).to match(/this one too #{AppConfig.url_to("/posts/#{target2.guid}")}./)
        end

        it "doesn't touch invalid diaspora:// links" do
          text = "You can create diaspora://author/type/guid links!"
          expect(message(text).markdownified).to match(/#{text}/)
        end
      end
    end
  end

  describe "#plain_text_without_markdown" do
    it 'does not remove markdown in links' do
      text = "some text and here comes http://exampe.org/foo_bar_baz a link"
      expect(message(text).plain_text_without_markdown).to eq text
    end

    it 'does not destroy hashtag that starts a line' do
      text = "#hashtag message"
      expect(message(text).plain_text_without_markdown).to eq text
    end

    context "with mention" do
      it "contains the name of the mentioned person" do
        msg = message("@{#{alice.diaspora_handle}} is cool", mentioned_people: alice.person)
        expect(msg.plain_text_without_markdown).to eq "@#{alice.name} is cool"
      end

      it "uses the name from mention when the mention contains a name" do
        msg = message("@{Alice; #{alice.diaspora_handle}} is cool", mentioned_people: alice.person)
        expect(msg.plain_text_without_markdown).to eq "@Alice is cool"
      end

      it "uses the diaspora ID when the person cannot be found" do
        msg = message("@{#{alice.diaspora_handle}} is cool", mentioned_people: [])
        expect(msg.plain_text_without_markdown).to eq "@#{alice.diaspora_handle} is cool"
      end
    end

    context "with diaspora:// links" do
      it "replaces diaspora:// links with pod-local links" do
        target1 = FactoryGirl.create(:status_message)
        target2 = FactoryGirl.create(:status_message)
        text = "Have a look at [this post](diaspora://#{target1.diaspora_handle}/post/#{target1.guid}) and " \
               "this one too diaspora://#{target2.diaspora_handle}/post/#{target2.guid}."

        rendered = message(text).plain_text_without_markdown

        expect(rendered).to match(/look at this post \(#{AppConfig.url_to("/posts/#{target1.guid}")}\) and/)
        expect(rendered).to match(/this one too #{AppConfig.url_to("/posts/#{target2.guid}")}./)
      end

      it "doesn't touch invalid diaspora:// links" do
        text = "You can create diaspora://author/type/guid links!"
        expect(message(text).plain_text_without_markdown).to match(/#{text}/)
      end
    end
  end

  describe "#urls" do
    it "extracts the urls from the raw message" do
      text = "[Perdu](http://perdu.com/) and [DuckDuckGo](https://duckduckgo.com/) can help you"
      expect(message(text).urls).to eql ["http://perdu.com/", "https://duckduckgo.com/"]
    end

    it "extracts urls from continous markdown correctly" do
      text = "[![Image](https://www.antifainfoblatt.de/sites/default/files/public/styles/front_full/public/jockpalfreeman.png?itok=OPjHKpmt)](https://www.antifainfoblatt.de/artikel/%E2%80%9Eschlie%C3%9Flich-waren-es-zu-viele%E2%80%9C)"
      expect(message(text).urls).to eq ["https://www.antifainfoblatt.de/sites/default/files/public/styles/front_full/public/jockpalfreeman.png?itok=OPjHKpmt", "https://www.antifainfoblatt.de/artikel/%E2%80%9Eschlie%C3%9Flich-waren-es-zu-viele%E2%80%9C"]
    end

    it "encodes extracted urls" do
      url = "http://www.example.com/url/with/umlauts/ä/index.html"
      expect(message(url).urls).to eq ["http://www.example.com/url/with/umlauts/%C3%A4/index.html"]
    end

    it "not double encodes an already encoded url" do
      encoded_url = "http://www.example.com/url/with/umlauts/%C3%A4/index.html"
      expect(message(encoded_url).urls).to eq [encoded_url]
    end

    it "parses IDN correctly" do
      url = "http://www.hören.at/"
      expect(message(url).urls).to eq ["http://www.xn--hren-5qa.at/"]
    end
  end

  describe "#plain_text_for_json" do
    it "normalizes" do
      {
        "\u202a#\u200eUSA\u202c" => "#USA",
        "ള്‍"                    => "ള്‍"
      }.each do |input, output|
        expect(message(input).plain_text_for_json).to eq output
      end
    end

    context "with diaspora:// links" do
      it "replaces diaspora:// links with pod-local links" do
        target1 = FactoryGirl.create(:status_message)
        target2 = FactoryGirl.create(:status_message)
        text = "Have a look at [this post](diaspora://#{target1.diaspora_handle}/post/#{target1.guid}) and " \
               "this one too diaspora://#{target2.diaspora_handle}/post/#{target2.guid}."

        rendered = message(text).plain_text_for_json

        expect(rendered).to match(/look at \[this post\]\(#{AppConfig.url_to("/posts/#{target1.guid}")}\) and/)
        expect(rendered).to match(/this one too #{AppConfig.url_to("/posts/#{target2.guid}")}./)
      end

      it "doesn't touch invalid diaspora:// links" do
        text = "You can create diaspora://author/type/guid links!"
        expect(message(text).plain_text_for_json).to match(/#{text}/)
      end
    end
  end
end
