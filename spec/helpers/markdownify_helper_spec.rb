#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe MarkdownifyHelper do

  describe "#markdownify" do
    describe "not doing something dumb" do
      it "strips out script tags" do
        markdownify("<script>alert('XSS is evil')</script>").should ==
          "<p>alert(&#39;XSS is evil&#39;)</p>\n"
      end

      it 'strips onClick handlers from links' do
        omghax = '[XSS](http://joindiaspora.com/" onClick="$\(\'a\'\).remove\(\))'
        markdownify(omghax).should_not match(/ onClick/i)
      end
    end

    it 'does not barf if message is nil' do
      markdownify(nil).should == ''
    end

    it 'autolinks standard url links' do
      markdownified = markdownify("http://joindiaspora.com/")

      doc = Nokogiri.parse(markdownified)

      link = doc.css("a")

      link.attr("href").value.should == "http://joindiaspora.com/"
    end

    context 'when formatting status messages' do
      it "should leave tags intact" do
        message = FactoryGirl.create(:status_message,
                                 :author => alice.person,
                                 :text => "I love #markdown")
        formatted = markdownify(message)
        formatted.should =~ %r{<a href="/tags/markdown" class="tag">#markdown</a>}
      end

      it 'should leave multi-underscore tags intact' do
        message = FactoryGirl.create(
          :status_message,
          :author => alice.person,
          :text => "Here is a #multi_word tag"
        )
        formatted = markdownify(message)
        formatted.should =~ %r{Here is a <a href="/tags/multi_word" class="tag">#multi_word</a> tag}

        message = FactoryGirl.create(
          :status_message,
          :author => alice.person,
          :text => "Here is a #multi_word_tag yo"
        )
        formatted = markdownify(message)
        formatted.should =~ %r{Here is a <a href="/tags/multi_word_tag" class="tag">#multi_word_tag</a> yo}
      end

      it "should leave mentions intact" do
        message = FactoryGirl.create(:status_message,
                                 :author => alice.person,
                                 :text => "Hey @{Bob; #{bob.diaspora_handle}}!")
        formatted = markdownify(message)
        formatted.should =~ /hovercard/
      end

      it "should leave mentions intact for real diaspora handles" do
        new_person = FactoryGirl.create(:person, :diaspora_handle => 'maxwell@joindiaspora.com')
        message = FactoryGirl.create(:status_message,
                                 :author => alice.person,
                                 :text => "Hey @{maxwell@joindiaspora.com; #{new_person.diaspora_handle}}!")
        formatted = markdownify(message)
        formatted.should =~ /hovercard/
      end

      it 'should process text with both a hashtag and a link' do
        message = FactoryGirl.create(:status_message,
                                 :author => alice.person,
                                 :text => "Test #tag?\nhttps://joindiaspora.com\n")
        formatted = markdownify(message)
        formatted.should == %{<p>Test <a href="/tags/tag" class="tag">#tag</a>?<br>\n<a href="https://joindiaspora.com" target="_blank">https://joindiaspora.com</a></p>\n}
      end
    end
  end
end
