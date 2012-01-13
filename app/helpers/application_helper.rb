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
    "javascript:(function(){f='#{AppConfig[:pod_url]}bookmarklet?url='+encodeURIComponent(window.location.href)+'&title='+encodeURIComponent(document.title)+'&notes='+encodeURIComponent(''+(window.getSelection?window.getSelection():document.getSelection?document.getSelection():document.selection.createRange().text))+'&v=1&';a=function(){if(!window.open(f+'noui=1&jump=doclose','diasporav1','location=yes,links=no,scrollbars=no,toolbar=no,width=620,height=250'))location.href=f+'jump=yes'};if(/Firefox/.test(navigator.userAgent)){setTimeout(a,0)}else{a()}})()"
  end

  def get_javascript_strings_for(language)
    defaults = I18n.t('javascripts', :locale => DEFAULT_LANGUAGE)

    if language != DEFAULT_LANGUAGE
      translations = I18n.t('javascripts', :locale => language)
      defaults.update(translations)
    end

    defaults
  end

  def direction_for(string)
    return '' unless string.respond_to?(:cleaned_is_rtl?)
    string.cleaned_is_rtl? ? 'rtl' : 'ltr'
  end

  def rtl?
    @rtl ||= RTL_LANGUAGES.include? I18n.locale
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

  def jquery_include_tag
    javascript_include_tag('//ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js') +
    content_tag(:script) do
      "!window.jQuery && document.write(unescape(\"#{escape_javascript(include_javascripts(:jquery))}\")); jQuery.ajaxSetup({'cache': false});".html_safe
    end
  end
end
