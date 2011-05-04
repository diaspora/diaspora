#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ApplicationHelper do
  before do
    @user = alice
    @person = Factory.create(:person)
  end

  describe "#object_path" do
    it "returns an empty string if object is nil" do
      object_path(nil).should == ""
    end
    it "returns person path if it's a person" do
      object_path(@person).should == person_path(@person)
    end
    it "returns person path if it's a user" do
      object_path(@user).should == person_path(@user.person)
    end
  end

  describe "#person_image_link" do
    it "returns an empty string if person is nil" do
      person_image_link(nil).should == ""
    end
    it "returns a link containing the person's photo" do
      person_image_link(@person).should include(@person.profile.image_url)
    end
    it "returns a link to the person's profile" do
      person_image_link(@person).should include(person_path(@person))
    end
  end

  describe "#person_image_tag" do
    it "should not allow basic XSS/HTML" do
      @person.profile.first_name = "I'm <h1>Evil"
      @person.profile.last_name = "I'm <h1>Evil"
      person_image_tag(@person).should_not include("<h1>")
    end
  end

  describe "markdownify" do
    describe "autolinks" do
      it "should not allow basic XSS/HTML" do
        markdownify("<script>alert('XSS is evil')</script>").should == "&lt;script&gt;alert('XSS is evil')&lt;/script&gt;"
      end

      it "should recognize basic http links (1/3)" do
        proto="http"
        url="bugs.joindiaspora.com/issues/332"
        markdownify(proto+"://"+url).should == "<a target=\"_blank\" href=\""+proto+"://"+url+"\">"+url+"</a>"
      end

      it "should recognize basic http links (2/3)" do
        proto="http"
        url="webmail.example.com?~()!*/"
        markdownify(proto+"://"+url).should == "<a target=\"_blank\" href=\""+proto+"://"+url+"\">"+url+"</a>"
      end

      it "should recognize basic http links (3/3)" do
        proto="http"
        url="127.0.0.1:3000/users/sign_in"
        markdownify(proto+"://"+url).should == "<a target=\"_blank\" href=\""+proto+"://"+url+"\">"+url+"</a>"
      end

      it "should recognize secure https links" do
        proto="https"
        url="127.0.0.1:3000/users/sign_in"
        markdownify(proto+"://"+url).should == "<a target=\"_blank\" href=\""+proto+"://"+url+"\">"+url+"</a>"
      end



      describe "video links" do
        it "recognizes vimeo links" do
          video_id = "17449557"
          url = "http://www.vimeo.com/#{video_id}"
          res = markdownify(url)
          res.should =~ /data-host="vimeo.com"/
          res.should =~ /data-video-id="#{video_id}"/
        end

        it "recognizes youtube links" do
          video_id = "0x__dDWdf23"
          url = "http://www.youtube.com/watch?v=" + video_id + "&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
          res = markdownify(url)
          res.should =~ /Youtube:/
          res.should =~ /data-host="youtube.com"/
          res.should =~ /data-video-id="#{video_id}"/
        end

        it "recognizes youtube links with hyphens" do
          video_id = "ABYnqp-bxvg"
          url = "http://www.youtube.com/watch?v=" + video_id + "&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
          res = markdownify(url)
          res.should =~ /Youtube:/
          res.should =~ /data-host="youtube.com"/
          res.should =~ /data-video-id="#{video_id}"/
        end

        it "keeps anchors" do
          anchor = "#t=11m34"
          video_id = "DHRoHuv3I8E"
          url = "http://www.youtube.com/watch?v=" + video_id + anchor
          res = markdownify(url)
          res.should =~ /Youtube:/
          res.should =~ /data-host="youtube.com"/
          res.should =~ /data-video-id="#{video_id}"/
          res.should =~ /data-anchor="#{anchor}"/
        end
        
        it "has an empty data-anchor attribute if there is no anchor" do
          video_id = "DHRoHuv3I8E"
          url = "http://www.youtube.com/watch?v=" + video_id
          res = markdownify(url)
          res.should =~ /Youtube:/
          res.should =~ /data-host="youtube.com"/
          res.should =~ /data-video-id="#{video_id}"/
          res.should =~ /data-anchor=""/
        end

        it "leaves the links in the href of the #a tag" do
          video_id = "ABYnqp-bxvg"
          start_url ="http://www.youtube.com/watch?v=" + video_id
          url = start_url + "&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
          res = markdownify(url)
          res.should =~ /href=[\S]+v=#{video_id}/
        end
        it 'does not autolink inside the link' do
          video_id = "ABYnqp-bxvg"
          start_url ="http://www.youtube.com/watch?v=" + video_id
          url = start_url + "&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
          res = markdownify(url)
          res.match(/href="<a/).should be_nil
        end
      end

      it "recognizes multiple links of different types" do
        message = "http:// Hello World, this is for www.joindiaspora.com and not for http://www.google.com though their Youtube service is neat, take http://www.youtube.com/watch?v=foobar----- or www.youtube.com/watch?foo=bar&v=BARFOO-----&whatever=related It is a good idea we finally have youtube, so enjoy this video http://www.youtube.com/watch?v=rickrolld--"
        res = markdownify(message)
        res.should =~ /a target=\"_blank\" href=\"http:\/\/www.joindiaspora.com\"/
        res.should =~ /a target=\"_blank\" href=\"http:\/\/www.google.com\"/
        res.should =~ /data-video-id="foobar-----"/
        res.should =~ /data-video-id="BARFOO-----"/
        res.should =~ /data-video-id="rickrolld--"/
      end

      it "should recognize basic ftp links" do
        proto="ftp"
        url="ftp.uni-kl.de/CCC/26C3/mp4/26c3-3540-en-a_hackers_utopia.mp4"
        # I did not watch that one, but the title sounds nice :P
        markdownify(proto+"://"+url).should == "<a target=\"_blank\" href=\""+proto+"://"+url+"\">"+url+"</a>"
      end

      it "should recognize www links" do
        url="www.joindiaspora.com"
        markdownify(url).should == "<a target=\"_blank\" href=\"http://"+url+"\">"+url+"</a>"
      end
    end

    describe "emoticons" do
      it "replaces &lt;3 with &hearts;" do
        message = "i <3 you"
        markdownify(message).should == "i &hearts; you"
      end
      
      it "replaces various things with (their) HTML entities" do
        message = ":) :-) :( :-( ... -> <- (tm) (r) (c)"
        markdownify(message).should == "&#9786; &#9786; &#9785; &#9785; &hellip; &rarr; &larr; &trade; &reg; &copy;"
      end
      
      it "skips doing it if you say so" do
        message = ":) :-) :( :-( ... -> <-"
        markdownify(message, :emoticons => false).should == ":) :-) :( :-( ... -&gt; &lt;-"
      end
    end

    describe "weak emphasis" do
      it "should be recognized (1/2)" do
        message = "*some text* some text *some text* some text"
        markdownify(message).should == "<em>some text</em> some text <em>some text</em> some text"
      end

      it "should be recognized (2/2)" do
        message = "_some text_ some text _some text_ some text"
        markdownify(message).should == "<em>some text</em> some text <em>some text</em> some text"
      end
    end

    describe "strong emphasis" do
      it "should be recognized (1/2)" do
        message = "**some text** some text **some text** some text"
        markdownify(message).should == "<strong>some text</strong> some text <strong>some text</strong> some text"
      end

      it "should be recognized (2/2)" do
        message = "__some text__ some text __some text__ some text"
        markdownify(message).should == "<strong>some text</strong> some text <strong>some text</strong> some text"
      end
    end

    describe "nested weak and strong emphasis" do
      it "should be rendered correctly" do
        message = "__this is _some_ text__"
        markdownify(message).should == "<strong>this is <em>some</em> text</strong>"
        message = "*this is **some** text*"
        markdownify(message).should == "<em>this is <strong>some</strong> text</em>"
        message = "___some text___"
        markdownify(message).should == "<em><strong>some text</strong></em>"
      end
    end

    describe "links" do
      it "should be recognized without title attribute" do
        message = "[link text](http://someurl.com) [link text](http://someurl.com)"
        markdownify(message).should == '<a target="_blank" href="http://someurl.com">link text</a> <a target="_blank" href="http://someurl.com">link text</a>'
      end

      it "should be recognized with title attribute" do
        message = '[link text](http://someurl.com "some title") [link text](http://someurl.com "some title")'
        markdownify(message).should == '<a target="_blank" href="http://someurl.com" title="some title">link text</a> <a target="_blank" href="http://someurl.com" title="some title">link text</a>'
      end

      it "should have a robust link parsing" do
        message = "This [*text*](http://en.wikipedia.org/wiki/Text_(literary_theory)) with many [links](google.com) tests [_http_](http://google.com/search?q=with_multiple__underscores*and**asterisks), [___FTP___](ftp://ftp.uni-kl.de/CCC/26C3/mp4/26c3-3540-en-a_hackers_utopia.mp4 \"File Transfer Protocol\"), [**any protocol**](foo://bar.example.org/yes_it*makes*no_sense)"
        markdownify(message).should == 'This <a target="_blank" href="http://en.wikipedia.org/wiki/Text_(literary_theory)"><em>text</em></a> with many <a target="_blank" href="http://google.com">links</a> tests <a target="_blank" href="http://google.com/search?q=with_multiple__underscores*and**asterisks"><em>http</em></a>, <a target="_blank" href="ftp://ftp.uni-kl.de/CCC/26C3/mp4/26c3-3540-en-a_hackers_utopia.mp4" title="File Transfer Protocol"><em><strong>FTP</strong></em></a>, <a target="_blank" href="foo://bar.example.org/yes_it*makes*no_sense"><strong>any protocol</strong></a>'
      end
    end

    describe "nested emphasis and links tags" do
      it "should be rendered correctly" do
        message = '[**some *link* text**](someurl.com "some title")'
        markdownify(message).should == '<a target="_blank" href="http://someurl.com" title="some title"><strong>some <em>link</em> text</strong></a>'
      end
    end

    it "should allow escaping" do
      message = '*some text* \\*some text* \\**some text* _some text_ \\_some text_ \\__some text_'
      markdownify(message).should == "<em>some text</em> *some text<em> **some text</em> <em>some text</em> _some text<em> __some text</em>"
    end

    describe "newlines" do
      it 'skips inserting newlines if you pass the newlines option' do
        message = "These\nare\n\some\nnew\lines"
        res = markdownify(message, :newlines => false)
        res.should == message
      end

      it 'generates breaklines' do
        message = "These\nare\nsome\nnew\nlines"
        res = markdownify(message)
        res.should == "These<br /\>are<br /\>some<br /\>new<br /\>lines"
      end

      it 'should render newlines and basic http links correctly' do
        message = "Some text, then a line break and a link\nhttp://joindiaspora.com\nsome more text"
        res = markdownify(message)
        res.should == 'Some text, then a line break and a link<br /><a target="_blank" href="http://joindiaspora.com">joindiaspora.com</a><br />some more text'
      end
    end

    describe '#person_link' do
      before do
      @person = Factory(:person)
      end
      it 'includes the name of the person if they have a first name' do
        person_link(@person).should include @person.profile.first_name
      end

      it 'uses diaspora handle if the person has no first or last name' do
        @person.profile.first_name = nil
        @person.profile.last_name = nil

        person_link(@person).should include @person.diaspora_handle
      end

      it 'uses diaspora handle if first name and first name are rails#blank?' do
        @person.profile.first_name = " "
        @person.profile.last_name = " "

        person_link(@person).should include @person.diaspora_handle
      end

      it "should not allow basic XSS/HTML" do
        @person.profile.first_name = "I'm <h1>Evil"
        @person.profile.last_name = "I'm <h1>Evil"
        person_link(@person).should_not include("<h1>")
      end
    end
    context 'performance' do
      before do
        @message = "HHello,Hello_, I _am a strong robot.*Hello, I am *a strong robot.Hello, I am a strong robot.Hello, I am a strong robot.Hello, I am a strong robot.Hello, I am a **strong robot.Hello, I am _a _strong *robot**.Hello*, I am a strong "
      end
      it 'is sub millisecond' do
        Benchmark.realtime{
          markdownify(@message)
        }.should < 0.001
      end
    end
  end
end
