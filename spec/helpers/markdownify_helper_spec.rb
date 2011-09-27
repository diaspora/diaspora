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
      markdownify("http://joindiaspora.com/").should match /<p><a href="http:\/\/joindiaspora.com\/">http:\/\/joindiaspora.com\/<\/a><\/p>/
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

      context 'when posting a link with oEmbed support' do
        scenarios = {
          "photo" => {
            "oembed_data" => {
              "trusted_endpoint_url" => "__!SPOOFED!__",
              "version" => "1.0",
              "type" => "photo",
              "title" => "ZB8T0193",
              "width" => "240",
              "height" => "160",
              "url" => "http://farm4.static.flickr.com/3123/2341623661_7c99f48bbf_m.jpg"
            },
            "link_url" => 'http://www.flickr.com/photos/bees/2341623661',
            "oembed_get_request" => "http://www.flickr.com/services/oembed/?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://www.flickr.com/photos/bees/2341623661",
          },

          "unsupported" => {
            "oembed_data" => "",
            "oembed_get_request" => 'http://www.we-do-not-support-oembed.com/index.html',
            "link_url" => 'http://www.we-do-not-support-oembed.com/index.html'
          },

          "secure_video" => {
            "oembed_data" => {
	            "version" => "1.0",
	            "type" => "video",
	            "width" => 425,
	            "height" => 344,
	            "title" => "Amazing Nintendo Facts",
	            "html" => "<object width=\"425\" height=\"344\">
			            <param name=\"movie\" value=\"http://www.youtube.com/v/M3r2XDceM6A&fs=1\"></param>
			            <param name=\"allowFullScreen\" value=\"true\"></param>
			            <param name=\"allowscriptaccess\" value=\"always\"></param>
			            <embed src=\"http://www.youtube.com/v/M3r2XDceM6A&fs=1\"
				            type=\"application/x-shockwave-flash\" width=\"425\" height=\"344\"
				            allowscriptaccess=\"always\" allowfullscreen=\"true\"></embed>
		            </object>",
            },
            "link_url" => "http://youtube.com/watch?v=M3r2XDceM6A&format=json",
            "oembed_get_request" => "http://www.youtube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://youtube.com/watch?v=M3r2XDceM6A",
          },

          "unsecure_video" => {
            "oembed_data" => {
	            "version" => "1.0",
	            "type" => "video",
	            "title" => "This is a video from an unsecure source",
	            "html" => "<object width=\"425\" height=\"344\">
			            <param name=\"movie\" value=\"http://www.youtube.com/v/M3r2XDceM6A&fs=1\"></param>
			            <param name=\"allowFullScreen\" value=\"true\"></param>
			            <param name=\"allowscriptaccess\" value=\"always\"></param>
			            <embed src=\"http://www.youtube.com/v/M3r2XDceM6A&fs=1\"
				            type=\"application/x-shockwave-flash\" width=\"425\" height=\"344\"
				            allowscriptaccess=\"always\" allowfullscreen=\"true\"></embed>
		            </object>",
            },
            "link_url" => "http://mytube.com/watch?v=M3r2XDceM6A&format=json",
            "discovery_data" => '<link rel="alternate" type="application/json+oembed" href="http://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://mytube.com/watch?v=M3r2XDceM6A" />',
            "oembed_get_request" => "http://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://mytube.com/watch?v=M3r2XDceM6A",
          },

          "secure_rich" => {
            "oembed_data" => {
	            "version" => "1.0",
	            "type" => "rich",
	            "width" => 425,
	            "height" => 344,
	            "title" => "Amazing Nintendo Facts",
	            "html" => "<object width=\"425\" height=\"344\">
			            <param name=\"movie\" value=\"http://www.youtube.com/v/M3r2XDceM6A&fs=1\"></param>
			            <param name=\"allowFullScreen\" value=\"true\"></param>
			            <param name=\"allowscriptaccess\" value=\"always\"></param>
			            <embed src=\"http://www.youtube.com/v/M3r2XDceM6A&fs=1\"
				            type=\"application/x-shockwave-flash\" width=\"425\" height=\"344\"
				            allowscriptaccess=\"always\" allowfullscreen=\"true\"></embed>
		            </object>",
            },
            "link_url" => "http://youtube.com/watch?v=M3r2XDceM6A&format=json",
            "oembed_get_request" => "http://www.youtube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://youtube.com/watch?v=M3r2XDceM6A",
          },

          "unsecure_rich" => {
            "oembed_data" => {
	            "version" => "1.0",
	            "type" => "rich",
	            "title" => "This is a video from an unsecure source",
	            "html" => "<object width=\"425\" height=\"344\">
			            <param name=\"movie\" value=\"http://www.youtube.com/v/M3r2XDceM6A&fs=1\"></param>
			            <param name=\"allowFullScreen\" value=\"true\"></param>
			            <param name=\"allowscriptaccess\" value=\"always\"></param>
			            <embed src=\"http://www.youtube.com/v/M3r2XDceM6A&fs=1\"
				            type=\"application/x-shockwave-flash\" width=\"425\" height=\"344\"
				            allowscriptaccess=\"always\" allowfullscreen=\"true\"></embed>
		            </object>",
            },
            "link_url" => "http://mytube.com/watch?v=M3r2XDceM6A&format=json",
            "discovery_data" => '<link rel="alternate" type="application/json+oembed" href="http://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://mytube.com/watch?v=M3r2XDceM6A" />',
            "oembed_get_request" => "http://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://mytube.com/watch?v=M3r2XDceM6A",
          },
        }

        scenarios.each do |type, data|
          specify 'for type "'+type+'"' do
            url = 
            stub_request(:get, data['link_url']).to_return(:status => 200, :body => data['discovery_data']) if data.has_key?('discovery_data')
            stub_request(:get, data['oembed_get_request']).to_return(:status => 200, :body => data['oembed_data'].to_json.to_s)

            message = "Look at this! "+data['link_url']
            Jobs::GatherOEmbedData.perform(message)
            OEmbedCache.find_by_url(data['link_url']).should_not be_nil unless type == 'unsupported'

            formatted = markdownify(message, :oembed => true)
            case type
              when 'photo'
                formatted.should =~ /#{data['oembed_data']['url']}/
              when 'unsupported'
                formatted.should =~ /#{data['link_url']}/
              when 'secure_video', 'secure_rich'
                formatted.should =~ /#{data['oembed_data']['html']}/
              when 'unsecure_video', 'unsecure_rich'
                formatted.should_not =~ /#{data['oembed_data']['html']}/
                formatted.should =~ /#{data['oembed_data']['title']}/
                formatted.should =~ /#{data['oembed_data']['url']}/
            end
          end
        end

      end
    end
  end
end
