# frozen_string_literal: true

Given /^I have several oEmbed data in cache$/ do
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
      "oembed_data" => {},
      "oembed_get_request" => 'http://www.we-do-not-support-oembed.com/index.html',
      "link_url" => 'http://www.we-do-not-support-oembed.com/index.html',
      "discovery_data" => 'no LINK tag!',
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
        "thumbnail_url" => "http://i2.ytimg.com/vi/M3r2XDceM6A/hqdefault.jpg",
        "thumbnail_height" => 360,
        "thumbnail_width" => 480,
      },
      "link_url" => "http://youtube.com/watch?v=M3r2XDceM6A&format=json",
      "oembed_get_request" => "http://www.youtube.com/oembed?scheme=https&format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://youtube.com/watch?v=M3r2XDceM6A",
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
        "thumbnail_url" => "http://i2.ytimg.com/vi/M3r2XDceM6A/hqdefault.jpg",
        "thumbnail_height" => 360,
        "thumbnail_width" => 480,
      },
      "link_url" => "http://myrichtube.com/watch?v=M3r2XDceM6A&format=json",
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
        "thumbnail_url" => "http://i2.ytimg.com/vi/M3r2XDceM6A/hqdefault.jpg",
        "thumbnail_height" => 360,
        "thumbnail_width" => 480,
      },
      "link_url" => "http://yourichtube.com/watch?v=M3r2XDceM6A&format=json",
      "oembed_get_request" => "http://www.youtube.com/oembed?scheme=https&format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://youtube.com/watch?v=M3r2XDceM6A",
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
        "thumbnail_url" => "http://i2.ytimg.com/vi/M3r2XDceM6A/hqdefault.jpg",
        "thumbnail_height" => 360,
        "thumbnail_width" => 480,
      },
      "link_url" => "http://mytube.com/watch?v=M3r2XDceM6A&format=json",
      "discovery_data" => '<link rel="alternate" type="application/json+oembed" href="http://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://mytube.com/watch?v=M3r2XDceM6A" />',
      "oembed_get_request" => "http://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://mytube.com/watch?v=M3r2XDceM6A",
    },
  }
  scenarios.each do |type, data|
    unless type=='unsupported'
      url = data['oembed_get_request'].split('?')[0]
      store_data = data['oembed_data'].merge('trusted_endpoint_url' => url)
      oembed = OEmbedCache.new(:url => data['link_url']);
      oembed.data = store_data
      oembed.save!
    end
  end
end

Then /^I should see a video player$/ do
  visit aspects_path
  find('.post-content .oembed')
  find('.stream-container').should have_css('.post-content .oembed img')
end

Then /^I should not see a video player$/ do
  find('.stream-container').should_not have_css('.post-content .oembed img')
end

