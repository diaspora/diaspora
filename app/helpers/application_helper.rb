#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ApplicationHelper
  def pod_name
    AppConfig.settings.pod_name.present? ? AppConfig.settings.pod_name : "diaspora*"
  end

  def pod_version
    AppConfig.version.number.present? ? AppConfig.version.number : ""
  end

  def changelog_url
    url = "https://github.com/diaspora/diaspora/blob/master/Changelog.md"
    url.sub!('/master/', "/#{AppConfig.git_revision}/") if AppConfig.git_revision.present?
    url
  end

  def timeago(time, options={})
    timeago_tag(time, options.merge(:class => 'timeago', :title => time.iso8601, :force => true)) if time
  end

  def bookmarklet
    raw_bookmarklet
  end

  def raw_bookmarklet( height = 400, width = 620)
    "javascript:(function(){f='#{AppConfig.pod_uri.to_s}bookmarklet?url='+encodeURIComponent(window.location.href)+'&title='+encodeURIComponent(document.title)+'&notes='+encodeURIComponent(''+(window.getSelection?window.getSelection():document.getSelection?document.getSelection():document.selection.createRange().text))+'&v=1&';a=function(){if(!window.open(f+'noui=1&jump=doclose','diasporav1','location=yes,links=no,scrollbars=no,toolbar=no,width=#{width},height=#{height}'))location.href=f+'jump=yes'};if(/Firefox/.test(navigator.userAgent)){setTimeout(a,0)}else{a()}})()"
  end

  def magic_bookmarklet_link
    bookmarklet
  end

  def contacts_link
    if current_user.contacts.size > 0
      contacts_path
    else
      community_spotlight_path
    end
  end

  def all_services_connected?
    current_user.services.size == AppConfig.configured_services.size
  end

  def popover_with_close_html(without_close_html)
    without_close_html + link_to(content_tag(:div, nil, :class => 'icons-deletelabel'), "#", :class => 'close')
  end

  # Require jQuery from CDN if possible, falling back to vendored copy, and require
  # vendored jquery_ujs
  def jquery_include_tag
    buf = []
    if AppConfig.privacy.jquery_cdn?
      version = Jquery::Rails::JQUERY_VERSION
      buf << [ javascript_include_tag("//code.jquery.com/jquery-#{version}.min.js") ]
      buf << [ javascript_tag("!window.jQuery && document.write(unescape('#{j javascript_include_tag("jquery")}'));") ]
    else
      buf << [ javascript_include_tag('jquery') ]
    end
    buf << [ javascript_include_tag('jquery_ujs') ]
    buf << [ javascript_tag("jQuery.ajaxSetup({'cache': false});") ]
    buf << [ javascript_tag("$.fx.off = true;") ] if Rails.env.test?
    buf.join("\n").html_safe
  end
end
