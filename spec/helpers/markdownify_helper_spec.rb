#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe MarkdownifyHelper do

  describe "#markdownify" do
    it 'does not error if youtube_maps in the hash is explicitly set to nil' do
      expect{
        markdownify("http://www.youtube.com/watch?v=pZROlhHOvuo", :youtube_maps => nil)
      }.should_not raise_error
    end

    it 'does not error if youtube_maps in the hash is explicitly set to nil' do
      expect{
        markdownify("http://vimeo.com/18589934", :vimeo_maps => nil)
      }.should_not raise_error
    end
    
    describe "autolinks" do
      it "should not allow basic XSS/HTML" do
        markdownify("<script>alert('XSS is evil')</script>").should == "<p>&lt;script&gt;alert('XSS is evil')&lt;/script&gt;</p>"
      end

      it "should recognize basic http links (1/3)" do
        proto="http"
        url="bugs.joindiaspora.com/issues/332"
        full_url = "#{proto}://#{url}"
        markdownify(full_url).should == %Q{<p><a target="_blank" href="#{full_url}">#{url}</a></p>}
      end

      it "should recognize basic http links (2/3)" do
        proto="http"
        url="webmail.example.com?~()!*/"
        full_url = "#{proto}://#{url}"
        markdownify(full_url).should == %Q{<p><a target="_blank" href="#{full_url}">#{url}</a></p>}
      end

      it "should recognize basic http links (3/3)" do
        proto="http"
        url="127.0.0.1:3000/users/sign_in"
        full_url = "#{proto}://#{url}"
        markdownify(full_url).should == %Q{<p><a target="_blank" href="#{full_url}">#{url}</a></p>}
      end

      it "should recognize secure https links" do
        proto="https"
        url="127.0.0.1:3000/users/sign_in"
        full_url = "#{proto}://#{url}"
        markdownify(full_url).should == %Q{<p><a target="_blank" href="#{full_url}">#{url}</a></p>}
      end

      it "doesn't muck up code text" do
        message = %{`puts "Hello"`}
        markdownify(message).should =~ %r{<code>puts &quot;Hello&quot;</code>}
        message = %Q{~~~\nA\nB\n~~~\n}
        markdownify(message).should =~ %r{<pre><code>\nA\nB\n</code></pre>}
      end

      it "doesn't double parse video links" do
        message = "http://www.vimeo.com/17449557
                   http://www.youtube.com/watch?v=0x__dDWdf23&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1
                   http://youtu.be/x_CzD0GBD-4"
        res = markdownify(message)
        res.should =~ /href.+href.+href/m
        res.should_not =~ /href.+href.+href.+href/m
      end

      describe "video links" do
        it "recognizes vimeo links" do
          video_id = "17449557"
          url = "http://www.vimeo.com/#{video_id}"
          res = markdownify(url)
          res.should =~ /data-host="vimeo.com"/
          res.should =~ /data-video-id="#{video_id}"/
        end

        it "matches a trailing slash in a vimeo link" do
          video_id = "17449557"
          url = "http://www.vimeo.com/#{video_id}/"
          res = markdownify(url)
          res.should =~ /data-host="vimeo.com"/
          res.should =~ /data-video-id="#{video_id}"/
          res.should_not =~ />\//
        end

        it "recognizes youtube links" do
          video_id = "0x__dDWdf23"
          url = "http://www.youtube.com/watch?v=" + video_id + "&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
          res = markdownify(url)
          res.should =~ /Youtube:/
          res.should =~ /data-host="youtube.com"/
          res.should =~ /data-video-id="#{video_id}"/

          url = "www.youtube.com/watch?foo=bar&v=BARFOO-----&whatever=related"
          res = markdownify(url)
          res.should =~ /Youtube:/
          res.should =~ /data-host="youtube.com"/
          res.should =~ /data-video-id="BARFOO-----"/
        end

        it "recognizes youtu.be links" do
          video_id = "x_CzD0GBD-4"
          url =  "http://youtu.be/#{video_id}"
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
        markdownify(proto+"://"+url).should == "<p><a target=\"_blank\" href=\""+proto+"://"+url+"\">"+url+"</a></p>"
      end

      it "should recognize www links" do
        url="www.joindiaspora.com"
        markdownify(url).should == %Q{<p><a target="_blank" href="http://#{url}">#{url}</a></p>}
      end
    end

    describe "specialchars" do
      it "replaces &lt;3 with &hearts;" do
        message = "i <3 you"
        markdownify(message).should == "<p>i &hearts; you</p>"
      end

      it "replaces various things with (their) HTML entities" do
        message = "... <-> -> <- (tm) (r) (c)"
        markdownify(message).should == "<p>&hellip; &#8596; &rarr; &larr; &trade; &reg; &copy;</p>"
      end

      it "skips doing it if you say so" do
        message = "... -> <-"
        markdownify(message, :specialchars => false).should == "<p>... -&gt; &lt;-</p>"
      end
    end

    describe "weak emphasis" do
      it "should be recognized (1/2)" do
        message = "*some text* some text *some text* some text"
        markdownify(message).should == "<p><em>some text</em> some text <em>some text</em> some text</p>"
      end

      it "should be recognized (2/2)" do
        message = "_some text_ some text _some text_ some text"
        markdownify(message).should == "<p><em>some text</em> some text <em>some text</em> some text</p>"
      end
    end

    describe "strong emphasis" do
      it "should be recognized (1/2)" do
        message = "**some text** some text **some text** some text"
        markdownify(message).should == "<p><strong>some text</strong> some text <strong>some text</strong> some text</p>"
      end

      it "should be recognized (2/2)" do
        message = "__some text__ some text __some text__ some text"
        markdownify(message).should == "<p><strong>some text</strong> some text <strong>some text</strong> some text</p>"
      end
    end

    describe "nested weak and strong emphasis" do
      it "should be rendered correctly" do
        message = "__this is _some_ text__"
        markdownify(message).should == "<p><strong>this is <em>some</em> text</strong></p>"
        message = "*this is **some** text*"
        markdownify(message).should == "<p><em>this is <strong>some</strong> text</em></p>"
        message = "___some text___"
        markdownify(message).should == "<p><em><strong>some text</strong></em></p>"
      end
    end

    describe "links" do
      it "should be recognized without title attribute" do
        message = "[link text](http://someurl.com) [link text](http://someurl.com)"
        markdownify(message).should == '<p><a target="_blank" href="http://someurl.com">link text</a> <a target="_blank" href="http://someurl.com">link text</a></p>'
      end

      it "should be recognized with title attribute" do
        message = '[link text](http://someurl.com "some title") [link text](http://someurl.com "some title")'
        markdownify(message).should == '<p><a target="_blank" href="http://someurl.com" title="some title">link text</a> <a target="_blank" href="http://someurl.com" title="some title">link text</a></p>'
      end

      it "should have a robust link parsing" do
        message = "[wikipedia](http://en.wikipedia.org/wiki/Text_(literary_theory))"
        link = markdownify(message)
        link.should =~ %r{href="http://en.wikipedia.org/wiki/Text_%28literary_theory%29"}
        
        message = "[  links]( google.com)"
        markdownify(message).should == %Q{<p><a target="_blank" href="http://google.com">links</a></p>}

        message = "[_http_](http://google.com/search?q=with_multiple__underscores*and**asterisks )"
        markdownify(message).should == %Q{<p><a target="_blank" href="http://google.com/search?q=with_multiple__underscores*and**asterisks"><em>http</em></a></p>}
        message = %{[___FTP___]( ftp://ftp.uni-kl.de/CCC/26C3/mp4/26c3-3540-en-a_hackers_utopia.mp4 'File Transfer Protocol')}
        markdownify(message).should == %{<p><a target="_blank" href="ftp://ftp.uni-kl.de/CCC/26C3/mp4/26c3-3540-en-a_hackers_utopia.mp4" title="File Transfer Protocol"><em><strong>FTP</strong></em></a></p>}

        message = %{[**any protocol**](foo://bar.example.org/yes_it*makes*no_sense)}
        markdownify(message).should == %{<p><a target="_blank" href="foo://bar.example.org/yes_it*makes*no_sense"><strong>any protocol</strong></a></p>}

        message = "This [ *text* ]( http://en.wikipedia.org/wiki/Text_(literary_theory) ) with many [ links]( google.com) tests [_http_](http://google.com/search?q=with_multiple__underscores*and**asterisks ), [___FTP___]( ftp://ftp.uni-kl.de/CCC/26C3/mp4/26c3-3540-en-a_hackers_utopia.mp4 'File Transfer Protocol'), [**any protocol**](foo://bar.example.org/yes_it*makes*no_sense)"
        markdownify(message).should == '<p>This <a target="_blank" href="http://en.wikipedia.org/wiki/Text_%28literary_theory%29"><em>text</em></a> with many <a target="_blank" href="http://google.com">links</a> tests <a target="_blank" href="http://google.com/search?q=with_multiple__underscores*and**asterisks"><em>http</em></a>, <a target="_blank" href="ftp://ftp.uni-kl.de/CCC/26C3/mp4/26c3-3540-en-a_hackers_utopia.mp4" title="File Transfer Protocol"><em><strong>FTP</strong></em></a>, <a target="_blank" href="foo://bar.example.org/yes_it*makes*no_sense"><strong>any protocol</strong></a></p>'
      end

    end

    describe "nested emphasis and links tags" do
      it "should be rendered correctly" do
        message = '[**some *link* text**](someurl.com "some title")'
        markdownify(message).should == '<p><a target="_blank" href="http://someurl.com" title="some title"><strong>some <em>link</em> text</strong></a></p>'
      end
    end

    it "should allow escaping" do
      message = '*some text* \*some text* \**some text* _some text_ \_some text_ \__some text_'
      markdownify(message).should == "<p><em>some text</em> *some text* *<em>some text</em> <em>some text</em> _some text_ _<em>some text</em></p>"
    end

    describe "newlines" do
      it 'skips inserting newlines if you pass the newlines option' do
        message = "These\nare\n\some\nnew\lines"
        res = markdownify(message, :newlines => false)
        res.should == "<p>#{message}</p>"
      end

      it 'generates breaklines' do
        message = "These\nare\nsome\nnew\nlines"
        res = markdownify(message)
        res.should == "<p>These<br /\>are<br /\>some<br /\>new<br /\>lines</p>"
      end

      it 'should render newlines and basic http links correctly' do
        message = "Some text, then a line break and a link\nhttp://joindiaspora.com\nsome more text"
        res = markdownify(message)
        res.should == '<p>Some text, then a line break and a link<br /><a target="_blank" href="http://joindiaspora.com">joindiaspora.com</a><br />some more text</p>'
      end
    end

    it 'does not barf is message is nil' do
      markdownify(nil).should == ''
    end

    context 'when formatting status messages' do

      it "should leave tags intact" do
        message = Factory.create(:status_message, 
                                 :author => alice.person,
                                 :text => "I love #markdown")
        formatted = markdownify(message)
        formatted.should =~ %r{<a href="/tags/markdown" class="tag">#markdown</a>}
      end

      it "should leave mentions intact" do
        message = Factory.create(:status_message, 
                                 :author => alice.person,
                                 :text => "Hey @{Bob; #{bob.diaspora_handle}}!")
        formatted = markdownify(message)
        formatted.should =~ /hovercard/
      end

      it "should leave mentions intact for real diaspora handles" do
        new_person = Factory(:person, :diaspora_handle => 'maxwell@joindiaspora.com')
        message = Factory.create(:status_message, 
                                 :author => alice.person,
                                 :text => "Hey @{maxwell@joindiaspora.com; #{new_person.diaspora_handle}}!")
        formatted = markdownify(message)
        formatted.should =~ /hovercard/
      end
    end

    context 'performance', :performance => true do
      before do
        @message = "</p>HHello,Hello_, I _am a strong robot.*Hello, I am *a strong robot.Hello, I am a strong robot.Hello, I am a strong robot.Hello, I am a strong robot.Hello, I am a **strong robot.Hello, I am _a _strong *robot**.Hello*, I am a strong</p>"
      end

      it 'is sub millisecond' do
        Benchmark.realtime{
          markdownify(@message)
        }.should < 0.001
      end
    end
  end
end
