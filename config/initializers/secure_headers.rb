# frozen_string_literal: true

SecureHeaders::Configuration.default do |config|
  config.hsts = SecureHeaders::OPT_OUT # added by Rack::SSL

  csp = {
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
    csp[:script_src] << asset_host
    csp[:style_src] << asset_host
  end

  if AppConfig.chat.enabled?
    csp[:media_src] << "data:"

    unless AppConfig.chat.server.bosh.proxy?
      csp[:connect_src] << "#{AppConfig.pod_uri.host}:#{AppConfig.chat.server.bosh.port}"
    end
  end

  csp[:script_src] << "code.jquery.com" if AppConfig.privacy.jquery_cdn?
  csp[:form_action] << "www.paypal.com" if AppConfig.settings.paypal_donations.enable?

  csp[:report_uri] = [AppConfig.settings.csp.report_uri] if AppConfig.settings.csp.report_uri.present?

  if AppConfig.settings.csp.report_only?
    config.csp = SecureHeaders::OPT_OUT
    config.csp_report_only = csp if AppConfig.settings.csp.report_uri.present?
  else
    config.csp = csp
  end
end
