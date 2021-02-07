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
        "url" => "https://farm4.static.flickr.com/3123/2341623661_7c99f48bbf_m.jpg"
      },
      "link_url" => 'https://www.flickr.com/photos/bees/2341623661',
      "oembed_get_request" => "https://www.flickr.com/services/oembed/?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=https://www.flickr.com/photos/bees/2341623661",
    },

    "unsupported" => {
      "oembed_data" => {},
      "oembed_get_request" => 'https://www.we-do-not-support-oembed.com/index.html',
      "link_url" => 'https://www.we-do-not-support-oembed.com/index.html',
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
            <param name=\"movie\" value=\"https://www.youtube.com/v/M3r2XDceM6A&fs=1\"></param>
            <param name=\"allowFullScreen\" value=\"true\"></param>
            <param name=\"allowscriptaccess\" value=\"always\"></param>
            <embed src=\"https://www.youtube.com/v/M3r2XDceM6A&fs=1\"
	            type=\"application/x-shockwave-flash\" width=\"425\" height=\"344\"
	            allowscriptaccess=\"always\" allowfullscreen=\"true\"></embed>
          </object>",
        "thumbnail_url" => "https://i2.ytimg.com/vi/M3r2XDceM6A/hqdefault.jpg",
        "thumbnail_height" => 360,
        "thumbnail_width" => 480,
      },
      "link_url" => "https://youtube.com/watch?v=M3r2XDceM6A&format=json",
      "oembed_get_request" => "https://www.youtube.com/oembed?scheme=https&format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=https://youtube.com/watch?v=M3r2XDceM6A",
    },

    "unsecure_video" => {
      "oembed_data" => {
        "version" => "1.0",
        "type" => "video",
        "title" => "This is a video from an unsecure source",
        "html" => "<object width=\"425\" height=\"344\">
            <param name=\"movie\" value=\"https://www.youtube.com/v/M3r2XDceM6A&fs=1\"></param>
            <param name=\"allowFullScreen\" value=\"true\"></param>
            <param name=\"allowscriptaccess\" value=\"always\"></param>
            <embed src=\"https://www.youtube.com/v/M3r2XDceM6A&fs=1\"
	            type=\"application/x-shockwave-flash\" width=\"425\" height=\"344\"
	            allowscriptaccess=\"always\" allowfullscreen=\"true\"></embed>
          </object>",
        "thumbnail_url" => "https://i2.ytimg.com/vi/M3r2XDceM6A/hqdefault.jpg",
        "thumbnail_height" => 360,
        "thumbnail_width" => 480,
      },
      "link_url" => "https://myrichtube.com/watch?v=M3r2XDceM6A&format=json",
      "discovery_data" => '<link rel="alternate" type="application/json+oembed" href="https://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=https://mytube.com/watch?v=M3r2XDceM6A" />',
      "oembed_get_request" => "https://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=https://mytube.com/watch?v=M3r2XDceM6A",
    },

    "secure_rich" => {
      "oembed_data" => {
        "version" => "1.0",
        "type" => "rich",
        "width" => 425,
        "height" => 344,
        "title" => "Amazing Nintendo Facts",
        "html" => "<object width=\"425\" height=\"344\">
            <param name=\"movie\" value=\"https://www.youtube.com/v/M3r2XDceM6A&fs=1\"></param>
            <param name=\"allowFullScreen\" value=\"true\"></param>
            <param name=\"allowscriptaccess\" value=\"always\"></param>
            <embed src=\"https://www.youtube.com/v/M3r2XDceM6A&fs=1\"
	            type=\"application/x-shockwave-flash\" width=\"425\" height=\"344\"
	            allowscriptaccess=\"always\" allowfullscreen=\"true\"></embed>
          </object>",
        "thumbnail_url" => "https://i2.ytimg.com/vi/M3r2XDceM6A/hqdefault.jpg",
        "thumbnail_height" => 360,
        "thumbnail_width" => 480,
      },
      "link_url" => "https://yourichtube.com/watch?v=M3r2XDceM6A&format=json",
      "oembed_get_request" => "https://www.youtube.com/oembed?scheme=https&format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=https://youtube.com/watch?v=M3r2XDceM6A",
    },

    "unsecure_rich" => {
      "oembed_data" => {
        "version" => "1.0",
        "type" => "rich",
        "title" => "This is a video from an unsecure source",
        "html" => "<object width=\"425\" height=\"344\">
            <param name=\"movie\" value=\"https://www.youtube.com/v/M3r2XDceM6A&fs=1\"></param>
            <param name=\"allowFullScreen\" value=\"true\"></param>
            <param name=\"allowscriptaccess\" value=\"always\"></param>
            <embed src=\"https://www.youtube.com/v/M3r2XDceM6A&fs=1\"
	            type=\"application/x-shockwave-flash\" width=\"425\" height=\"344\"
	            allowscriptaccess=\"always\" allowfullscreen=\"true\"></embed>
          </object>",
        "thumbnail_url" => "https://i2.ytimg.com/vi/M3r2XDceM6A/hqdefault.jpg",
        "thumbnail_height" => 360,
        "thumbnail_width" => 480,
      },
      "link_url" => "https://mytube.com/watch?v=M3r2XDceM6A&format=json",
      "discovery_data" => '<link rel="alternate" type="application/json+oembed" href="https://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=https://mytube.com/watch?v=M3r2XDceM6A" />',
      "oembed_get_request" => "https://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=https://mytube.com/watch?v=M3r2XDceM6A",
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

