SecureHeaders::Configuration.default do |config|
  config.hsts = SecureHeaders::OPT_OUT # added by Rack::SSL

  config.csp = {
    default_src:     %w('none'),
    child_src:       %w('self' www.youtube.com w.soundcloud.com twitter.com platform.twitter.com syndication.twitter.com
                        player.vimeo.com www.mixcloud.com www.dailymotion.com media.ccc.de bandcamp.com
                        www.instagram.com),
    connect_src:     %w('self' embedr.flickr.com geo.query.yahoo.com nominatim.openstreetmap.org api.github.com),
    font_src:        %w('self'),
    form_action:     %w('self' platform.twitter.com syndication.twitter.com),
    frame_ancestors: %w('self'),
    img_src:         %w('self' data: *),
    media_src:       %w(https:),
    script_src:      %w('self' 'unsafe-eval' platform.twitter.com cdn.syndication.twimg.com widgets.flickr.com
                        embedr.flickr.com platform.instagram.com),
    style_src:       %w('self' 'unsafe-inline' platform.twitter.com *.twimg.com)
  }
end
