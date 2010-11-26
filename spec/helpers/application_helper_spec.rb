#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ApplicationHelper do
  before do
    @user = make_user
    @person = Factory.create(:person)
  end

  it "should provide a correct show path for a given person" do
    person_url(@person).should == "/people/#{@person.id}"
  end

  it "should provide a correct show path for a given user" do
    person_url(@user).should == "/users/#{@user.id}"
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
      person_image_link(@person).should include(image_or_default(@person))
    end
    it "returns a link to the person's profile" do
      person_image_link(@person).should include("href=\"#{person_path(@person)}\"")
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

      it "recognizes youtube links" do
        proto="http"
        videoid = "0x__dDWdf23"
        url="www.youtube.com/watch?v="+videoid+"&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
        title = "UP & down & UP & down &amp;"
        mock_http = mock("http")
        Net::HTTP.stub!(:new).with('gdata.youtube.com', 80).and_return(mock_http)
        mock_http.should_receive(:get).with('/feeds/api/videos/'+videoid+'?v=2', nil).and_return([nil, 'Foobar <title>'+title+'</title> hallo welt <asd><dasdd><a>dsd</a>'])
        res = markdownify(proto+'://'+url)
        res.should =~ /data-host="youtube.com"/
        res.should =~ /data-video-id="#{videoid}"/
      end
      
      it "recognizes youtube links with hyphens" do
        proto="http"
        videoid = "ABYnqp-bxvg"
        url="www.youtube.com/watch?v="+videoid+"&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
        title = "UP & down & UP & down &amp;"
        mock_http = mock("http")
        Net::HTTP.stub!(:new).with('gdata.youtube.com', 80).and_return(mock_http)
        mock_http.should_receive(:get).with('/feeds/api/videos/'+videoid+'?v=2', nil).and_return([nil, 'Foobar <title>'+title+'</title> hallo welt <asd><dasdd><a>dsd</a>'])
        res = markdownify(proto+'://'+url)
        res.should =~ /data-host="youtube.com"/
        res.should =~ /data-video-id="#{videoid}"/
      end

      it "recognizes multiple links of different types" do
        message = "http:// Hello World, this is for www.joindiaspora.com and not for http://www.google.com though their Youtube service is neat, take http://www.youtube.com/watch?v=foobar or www.youtube.com/watch?foo=bar&v=BARFOO&whatever=related It is a good idea we finally have youtube, so enjoy this video http://www.youtube.com/watch?v=rickrolld"
        mock_http = mock("http")
        Net::HTTP.stub!(:new).with('gdata.youtube.com', 80).and_return(mock_http)
        mock_http.should_receive(:get).with('/feeds/api/videos/foobar?v=2', nil).and_return([nil, 'Foobar <title>F 007 - the bar is not enough</title> hallo welt <asd><dasdd><a>dsd</a>'])
        mock_http.should_receive(:get).with('/feeds/api/videos/BARFOO?v=2', nil).and_return([nil, 'Foobar <title>BAR is the new FOO</title> hallo welt <asd><dasdd><a>dsd</a>'])
        mock_http.should_receive(:get).with('/feeds/api/videos/rickrolld?v=2', nil).and_return([nil, 'Foobar <title>Never gonne give you up</title> hallo welt <asd><dasdd><a>dsd</a>'])
        res = markdownify(message)
        res.should =~ /a target=\"_blank\" href=\"http:\/\/www.joindiaspora.com\"/
        res.should =~ /a target=\"_blank\" href=\"http:\/\/www.google.com\"/
        res.should =~ /data-video-id="foobar"/
        res.should =~ /data-video-id="BARFOO"/
        res.should =~ /data-video-id="rickrolld"/
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
    end

    describe "nested emphasis and links tags" do
      it "should be rendered correctly" do
        message = '[**some *link* text**](someurl.com "some title")'
        markdownify(message).should == '<a target="_blank" href="someurl.com" title="some title"><strong>some <em>link</em> text</strong></a>'
      end
    end

    it "should allow escaping" do
      message = '*some text* \\*some text* \\**some text* _some text_ \\_some text_ \\__some text_'
      markdownify(message).should == "<em>some text</em> *some text<em> *</em>some text <em>some text</em> _some text<em> _</em>some text"
    end

    describe "options" do
      before do
        @message = "http://url.com www.url.com www.youtube.com/watch?foo=bar&v=BARFOO&whatever=related *emphasis* __emphasis__ [link](www.url.com) [link](url.com \"title\")"
      end

      it "can render only autolinks" do
        res = markdownify(@message, :youtube => false, :emphasis => false, :links => false)
        res.should == "<a target=\"_blank\" href=\"http://url.com\">url.com</a> <a target=\"_blank\" href=\"http://www.url.com\">www.url.com</a> <a target=\"_blank\" href=\"http://www.youtube.com/watch?foo=bar&amp;v=BARFOO&amp;whatever=related\">www.youtube.com/watch?foo=bar&amp;v=BARFOO&amp;whatever=related</a> *emphasis* __emphasis__ [link](www.url.com) [link](url.com &quot;title&quot;)"
      end

      it "can render only youtube" do
        res = markdownify(@message, :autolinks => false, :emphasis => false, :links => false)
        res.should_not =~ /a href="http:\/\/url.com"/
        res.should_not =~ /a href="http:\/\/www.url.com"/
        res.should_not =~ /<strong>emphasis<\/strong>/
      end

      it "can render only emphasis tags" do
        res = markdownify(@message, :autolinks => false, :youtube => false, :links => false)
        res.should == "http://url.com www.url.com www.youtube.com/watch?foo=bar&amp;v=BARFOO&amp;whatever=related <em>emphasis</em> <strong>emphasis</strong> [link](www.url.com) [link](url.com &quot;title&quot;)"
      end

      it "can render only links tags" do
        res = markdownify(@message, :autolinks => false, :youtube => false, :emphasis => false)
        res.should == "http://url.com www.url.com www.youtube.com/watch?foo=bar&amp;v=BARFOO&amp;whatever=related *emphasis* __emphasis__ <a target=\"_blank\" href=\"www.url.com\">link</a> <a target=\"_blank\" href=\"url.com\" title=\"title\">link</a>"
      end
    end
  end
end
