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
                        embedr.flickr.com platform.instagram.com 'unsafe-inline'),
    style_src:       %w('self' 'unsafe-inline' platform.twitter.com *.twimg.com)
  }

  # Add frame-src but don't spam the log with DEPRECATION warnings.
  # We need frame-src to support older versions of Chrome, because secure_headers handles all Chrome browsers as
  # "modern" browser, and ignores the version of the browser. We can drop this once we support only Chrome
  # versions with child-src support.
  module SecureHeaders
    class ContentSecurityPolicy
      private

      def normalize_child_frame_src
        @config[:frame_src] = @config[:child_src]
      end
    end
  end
end
