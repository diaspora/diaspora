# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ApplicationHelper
  def pod_name
    AppConfig.settings.pod_name
  end

  def pod_version
    AppConfig.version.number
  end

  def changelog_url
    return AppConfig.settings.changelog_url.get if AppConfig.settings.changelog_url.present?

    url = "https://github.com/diaspora/diaspora/blob/master/Changelog.md"
    return url if AppConfig.git_revision.blank?

    url.sub("/master/", "/#{AppConfig.git_revision}/")
  end

  def source_url
    AppConfig.settings.source_url.presence || "#{root_path.chomp('/')}/source.tar.gz"
  end

  def donations_enabled?
    AppConfig.settings.paypal_donations.enable? ||
    AppConfig.settings.liberapay_username.present? ||
    AppConfig.bitcoin_donation_address.present?
  end

  def timeago(time, options={})
    timeago_tag(time, options.merge(:class => 'timeago', :title => time.iso8601, :force => true)) if time
  end

  def bookmarklet_code(height=400, width=620)
    "javascript:" +
      BookmarkletRenderer.body +
      "bookmarklet('#{bookmarklet_url}', #{width}, #{height});"
  end

  def all_services_connected?
    current_user.services.size == AppConfig.configured_services.size
  end

  def popover_with_close_html(without_close_html)
    without_close_html + link_to('&times;'.html_safe, "#", :class => 'close')
  end

  # Require jQuery from CDN if possible, falling back to vendored copy, and require
  # vendored jquery_ujs
  def jquery_include_tag
    buf = []
    if AppConfig.privacy.jquery_cdn?
      version = Jquery::Rails::JQUERY_3_VERSION
      buf << [javascript_include_tag("//code.jquery.com/jquery-#{version}.min.js")]
      buf << [
        nonced_javascript_tag("!window.jQuery && document.write(unescape('#{j javascript_include_tag('jquery3')}'));")
      ]
    else
      buf << [javascript_include_tag("jquery3")]
    end
    buf << [javascript_include_tag("jquery_ujs")]
    buf << [nonced_javascript_tag("jQuery.ajaxSetup({'cache': false});")]
    buf << [nonced_javascript_tag("$.fx.off = true;")] if Rails.env.test?
    buf.join("\n").html_safe
  end
end
