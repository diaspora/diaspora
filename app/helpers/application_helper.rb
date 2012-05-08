#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ApplicationHelper
  def how_long_ago(obj)
    timeago(obj.created_at)
  end

  def timeago(time, options={})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.iso8601)) if time
  end

  def bookmarklet
    raw_bookmarklet
  end

  def new_bookmarklet
    raw_bookmarklet(520, 720, true)
  end

  def raw_bookmarklet( height = 250, width = 620, new=false)
    route = new ? 'new_bookmarklet' : 'bookmarklet'
    "javascript:(function(){f='#{AppConfig[:pod_url]}#{route}?url='+encodeURIComponent(window.location.href)+'&title='+encodeURIComponent(document.title)+'&notes='+encodeURIComponent(''+(window.getSelection?window.getSelection():document.getSelection?document.getSelection():document.selection.createRange().text))+'&v=1&';a=function(){if(!window.open(f+'noui=1&jump=doclose','diasporav1','location=yes,links=no,scrollbars=no,toolbar=no,width=#{width},height=#{height}'))location.href=f+'jump=yes'};if(/Firefox/.test(navigator.userAgent)){setTimeout(a,0)}else{a()}})()"
  end

  def magic_bookmarklet_link
    if user_signed_in? && current_user.beta?
      new_bookmarklet
    else
      bookmarklet
    end
  end

  def contacts_link
    if current_user.contacts.size > 0
      contacts_path
    else
      community_spotlight_path
    end
  end

  def all_services_connected?
    current_user.services.size == AppConfig[:configured_services].size
  end

  def popover_with_close_html(without_close_html)
    without_close_html + link_to(image_tag('deletelabel.png'), "#", :class => 'close')
  end

  def diaspora_id_host
    User.diaspora_id_host
  end

  def modernizer_responsive_tag
    javascript_tag("Modernizr.mq('(min-width:0)') ||  document.write(unescape('#{j javascript_include_tag("mbp-respond.min")}'));")
  end

  # Require jQuery from CDN if possible, falling back to vendored copy, and require
  # vendored jquery_ujs
  def jquery_include_tag
    buf = []
    if AppConfig[:jquery_cdn]
      version = Jquery::Rails::JQUERY_VERSION
      buf << [ javascript_include_tag("//ajax.googleapis.com/ajax/libs/jquery/#{version}/jquery.min.js") ]
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
