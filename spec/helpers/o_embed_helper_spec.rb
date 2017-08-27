# frozen_string_literal: true

describe OEmbedHelper, :type => :helper do
  describe 'o_embed_html' do
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
          "trusted_endpoint_url" => ::OEmbed::Providers::Youtube.endpoint,
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
          "trusted_endpoint_url" => ::OEmbed::Providers::Youtube.endpoint,
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
        },
        "link_url" => "http://mytube.com/watch?v=M3r2XDceM6A&format=json",
        "discovery_data" => '<link rel="alternate" type="application/json+oembed" href="http://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://mytube.com/watch?v=M3r2XDceM6A" />',
        "oembed_get_request" => "http://www.mytube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&url=http://mytube.com/watch?v=M3r2XDceM6A",
      },
    }

    scenarios.each do |type, data|
      specify 'for type "'+type+'"' do
        real_data = data['oembed_data']
        cache =  OEmbedCache.new(:url => data['link_url'])
        cache.data = real_data
        formatted = o_embed_html(cache).gsub('https://', 'http://')
        case type
          when 'photo'
            expect(formatted).to match(/#{data['oembed_data']['url']}/)
          when 'unsupported'
            expect(formatted).to match(/#{data['link_url']}/)
          when 'secure_video', 'secure_rich'
            expect(formatted).to match(/#{data['oembed_data']['html']}/)
          when 'unsecure_video', 'unsecure_rich'
            expect(formatted).not_to match(/#{data['oembed_data']['html']}/)
            expect(formatted).to match(/#{data['oembed_data']['title']}/)
            expect(formatted).to match(/#{data['oembed_data']['url']}/)
        end
      end
    end
  end
end
