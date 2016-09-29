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

  if AppConfig.environment.assets.host.present?
    asset_host = Addressable::URI.parse(AppConfig.environment.assets.host.get).host
    config.csp[:script_src] << asset_host
    config.csp[:style_src] << asset_host
  end

  if AppConfig.chat.enabled?
    config.csp[:media_src] << "data:"

    unless AppConfig.chat.server.bosh.proxy?
      config.csp[:connect_src] << "#{AppConfig.pod_uri.host}:#{AppConfig.chat.server.bosh.port}"
    end
  end

  if AppConfig.privacy.mixpanel_uid.present?
    config.csp[:script_src] << "api.mixpanel.com"
    config.csp[:connect_src] << "api.mixpanel.com"
  end

  config.csp[:script_src] << "code.jquery.com" if AppConfig.privacy.jquery_cdn?
  config.csp[:script_src] << "static.chartbeat.com" if AppConfig.privacy.chartbeat_uid.present?
  config.csp[:form_action] << "www.paypal.com" if AppConfig.settings.paypal_donations.enable?

  config.csp[:report_only] = AppConfig.settings.csp.report_only?
  config.csp[:report_uri] = [AppConfig.settings.csp.report_uri] if AppConfig.settings.csp.report_uri.present?

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
