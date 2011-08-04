#   Copyright (c) 2010, Diaspora Inc.  This file is
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

  def object_fields(object)
    object.attributes.keys
  end

  def mine?(post)
    current_user.owns? post
  end

  def type_partial(post)
    class_name = post.class.name.to_s.underscore
    "#{class_name.pluralize}/#{class_name}"
  end

  def profile_photo(person)
    person_image_link(person, :size => :thumb_large, :to => :photos)
  end

  def owner_image_tag(size=nil)
    person_image_tag(current_user.person, size)
  end

  def owner_image_link
    person_image_link(current_user.person)
  end

  def person_image_tag(person, size=nil)
    size ||= :thumb_small
    "<img alt=\"#{h(person.name)}\" class=\"avatar\" data-person_id=\"#{person.id}\" src=\"#{person.profile.image_url(size)}\" title=\"#{h(person.name)} (#{h(person.diaspora_handle)})\">".html_safe
  end

  def person_link(person, opts={})
    opts[:class] ||= ""
    opts[:class] << " self" if defined?(user_signed_in?) && user_signed_in? && current_user.person == person
    remote_or_hovercard_link = "/people/#{person.id}".html_safe
    if person.local?
          "<a data-hovercard='#{remote_or_hovercard_link}' href='/u/#{person.diaspora_handle.split('@')[0]}' class='#{opts[:class]}'>
        #{h(person.name)}
      </a>".html_safe
    else
          "<a href='#{remote_or_hovercard_link}' data-hovercard='#{remote_or_hovercard_link}' class='#{opts[:class]}' >
        #{h(person.name)}
      </a>".html_safe
    end
  end

  def hard_link(string, path)
    link_to string, path, :rel => 'external'
  end

  def person_image_link(person, opts={})
    return "" if person.nil? || person.profile.nil?
    if opts[:to] == :photos
      link_to person_image_tag(person, opts[:size]), person_photos_path(person)
    else
      if person.local?
        "<a href='/u/#{person.diaspora_handle.split('@')[0]}' class='#{opts[:class]}'>
        #{person_image_tag(person, opts[:size])}
        </a>".html_safe
      else
        "<a href='/people/#{person.id}'>
        #{person_image_tag(person, opts[:size])}
        </a>".html_safe
      end
    end
  end

  def post_yield_tag(post)
    (':' + post.id.to_s).to_sym
  end

  def info_text(text)
    image_tag 'icons/monotone_question.png', :class => 'what_is_this', :title => text
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

  def controller_index_path
    kontroller = request.filtered_parameters["controller"]
    if kontroller.downcase != "contacts"
      kontroller = "aspects"
    end
    self.send((kontroller + "_path").to_sym)
  end

  def left_nav_root
    if request.filtered_parameters["controller"] == "contacts"
      t('contacts.index.my_contacts')
    else
      t('aspects.index.your_aspects')
    end
  end

  def contacts_link
    if current_user.contacts.size > 0
      contacts_path
    else
      featured_users_path
    end
  end

  def all_services_connected?
    current_user.services.size == AppConfig[:configured_services].size
  end
end
