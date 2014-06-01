require 'spec_helper'

describe Diaspora::MessageRenderer do
  def message text, opts={}
    Diaspora::MessageRenderer.new(text, opts)
  end

  describe '#title' do
    context 'when :length is passed in parameters' do
      it 'returns string of size less or equal to :length' do
        string_size = 12
        title = message("## My title\n Post content...").title(length: string_size)
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
      end

      context 'without a Markdown header of less than 200 characters on first line ' do
        it 'truncates posts to the 20 first characters' do
          expect(message("Very, very, very long post").title).to eq "Very, very, very ..."
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
        message("http://joindiaspora.com/"
      ).markdownified).to include 'href="http://joindiaspora.com/"'
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
        ).to eq %{<p>Test <a class="tag" href="/tags/tag">#tag</a>?<br>\n<a href="https://joindiaspora.com" target="_blank">https://joindiaspora.com</a></p>\n}
      end

      it 'should process text with a header' do
        expect(message("# I love markdown").markdownified).to match "I love markdown"
      end

      it 'should leave HTML entities intact' do
        entities = '&amp; &szlig; &#x27; &#39; &quot;'
        expect(message(entities).markdownified).to eq "<p>#{entities}</p>\n"
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
  end
end
