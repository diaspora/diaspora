#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ApplicationHelper
  @@youtube_title_cache = Hash.new("no-title")
  def time_for_sort post
    post.created_at
  end

  def timeago(time, options={})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.iso8601)) if time
  end

  def page_title(text=nil)
    return text unless text.blank?
    current_user ? current_user.name : t("application.helper.diaspora_alpha")
  end

  def aspects_with_post(aspects, post)
    aspects.select do |aspect|
      AspectVisibility.exists?(:aspect_id => aspect.id, :post_id => post.id)
    end
  end

  def aspects_without_post(aspects, post)
    aspects.reject do |aspect|
      AspectVisibility.exists?(:aspect_id => aspect.id, :post_id => post.id)
    end
  end

  def aspect_badges(aspects, opts={})
    str = ''
    aspects.each do |aspect|
      str << aspect_badge(aspect, opts)
    end
    str.html_safe
  end

  def bookmarklet
    "javascript:(function(){f='#{AppConfig[:pod_url]}bookmarklet?url='+encodeURIComponent(window.location.href)+'&title='+encodeURIComponent(document.title)+'&notes='+encodeURIComponent(''+(window.getSelection?window.getSelection():document.getSelection?document.getSelection():document.selection.createRange().text))+'&v=1&';a=function(){if(!window.open(f+'noui=1&jump=doclose','diasporav1','location=yes,links=no,scrollbars=no,toolbar=no,width=620,height=250'))location.href=f+'jump=yes'};if(/Firefox/.test(navigator.userAgent)){setTimeout(a,0)}else{a()}})()"
  end

  def aspect_badge(aspect, opts={})
    str = "<span class='aspect_badge single'>"
    link = opts.delete(:link)
    if !link
      str << link_to(aspect.name, "#", 'data-guid' => aspect.id, :class => 'hard_aspect_link').html_safe
    else
      str << link_for_aspect(aspect).html_safe
    end
    str << "</span>"
  end

  def aspect_links(aspects, opts={})
    str = ""
    aspects.each do |aspect|
      str << '<li>'
      str << link_for_aspect(aspect, :params => opts, 'data-guid' => aspect.id, :class => 'hard_aspect_link').html_safe
      str << '</li>'
    end
    str.html_safe
  end

  def aspect_li(aspect, opts={})
    param_string = ""
    if opts.size > 0
      param_string << '?'
      opts.each_pair do |k, v|
        param_string << "#{k}=#{v}"
      end
    end
"<li>
  <a href='/aspects/#{aspect.id}#{param_string}'>
    #{aspect.name}
  </a>
</li>".html_safe
  end

  def link_for_aspect(aspect, opts={})
    opts[:params] ||= {}
    params ||= {}
    opts[:params] = opts[:params].merge("a_ids[]" => aspect.id, :created_at => params[:created_at])
    opts[:class] ||= ""
    opts[:class] << " hard_aspect_link"
    opts['data-guid'] = aspect.id

    link_to aspect.name, aspects_path( opts[:params] ), opts
  end

  def current_aspect?(aspect)
    !@aspect.nil? && !@aspect.instance_of?(Symbol) && @aspect.id == aspect.id
  end

  def aspect_or_all_path(aspect)
    if @aspect.is_a? Aspect
      aspect_path @aspect
    else
      aspects_path
    end
  end

  def object_path(object, opts={})
    return "" if object.nil?
    object = object.person if object.is_a? User
    eval("#{object.class.name.underscore}_path(object, opts)")
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

  def how_long_ago(obj)
    timeago(obj.created_at)
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

  def person_image_tag(person, size=:thumb_small)
    "<img alt=\"#{h(person.name)}\" class=\"avatar\" data-person_id=\"#{person.id}\" src=\"#{person.profile.image_url(size)}\" title=\"#{h(person.name)}\">".html_safe
  end

  def person_link(person, opts={})
    "<a href='/people/#{person.id}' class='#{opts[:class]}'>
  #{h(person.name)}
</a>".html_safe
  end

  def hard_link(string, path)
    link_to string, path, :rel => 'external'
  end

  def person_image_link(person, opts={})
    return "" if person.nil? || person.profile.nil?
    if opts[:to] == :photos
      link_to person_image_tag(person, opts[:size]), person_photos_path(person)
    else
      "<a href='/people/#{person.id}'>
  #{person_image_tag(person)}
</a>".html_safe
    end
  end

  def post_yield_tag(post)
    (':' + post.id.to_s).to_sym
  end

  def markdownify(message, options={})
    message = h(message).html_safe

    options[:newlines] = true if !options.has_key?(:newlines)
    options[:emoticons] = true if !options.has_key?(:emoticons)

    message = process_links(message)
    message = process_autolinks(message)
    message = process_emphasis(message)
    message = process_youtube(message, options[:youtube_maps])
    message = process_vimeo(message, options[:vimeo_maps])
    message = process_emoticons(message) if options[:emoticons]

    message.gsub!(/\n+/, '<br />') if options[:newlines]

    message
  end


  def process_links(message)
    message.gsub!(/\[([^\[]+)\]\(([^ ]+) \&quot;(([^&]|(&[^q])|(&q[^u])|(&qu[^o])|(&quo[^t])|(&quot[^;]))+)\&quot;\)/) do |m|
      escape = "\\"
      link = $1
      url = $2
      title = $3
      url.gsub!("_", "\\_")
      url.gsub!("*", "\\*")
      protocol = (url =~ /^\w+:\/\//) ? '' :'http://'
      res    = "<a target=\"#{escape}_blank\" href=\"#{protocol}#{url}\" title=\"#{title}\">#{link}</a>"
      res
    end

    message.gsub!(/\[([^\[]+)\]\(([^ ]+)\)/) do |m|
      escape = "\\"
      link = $1
      url = $2
      url.gsub!("_", "\\_")
      url.gsub!("*", "\\*")
      protocol = (url =~ /^\w+:\/\//) ? '' :'http://'
      res    = "<a target=\"#{escape}_blank\" href=\"#{protocol}#{url}\">#{link}</a>"
      res
    end

    message
  end

  def process_youtube(message, youtube_maps)
    processed_message = message.gsub(YoutubeTitles::YOUTUBE_ID_REGEX) do |matched_string|
      match_data = matched_string.match(YoutubeTitles::YOUTUBE_ID_REGEX)
      video_id = match_data[1]
      anchor = match_data[2]
      anchor ||= ''
      if youtube_maps && youtube_maps[video_id]
        title = h(CGI::unescape(youtube_maps[video_id]))
      else
        title = I18n.t 'application.helper.video_title.unknown'
      end
      ' <a class="video-link" data-host="youtube.com" data-video-id="' + video_id + '" data-anchor="' + anchor + '" href="'+ match_data[0].strip + '" target="_blank">Youtube: ' + title + '</a>'
    end
    processed_message
  end

  def process_autolinks(message)
    message.gsub!(/( |^)(www\.[^\s]+\.[^\s])/, '\1http://\2')
    message.gsub!(/(<a target="\\?_blank" href=")?(https|http|ftp):\/\/([^\s]+)/) do |m|
      captures = [$1,$2,$3]
      if !captures[0].nil?
        m
      elsif m.match(/(youtube|vimeo)/)
        m.gsub(/(\*|_)/) { |m| "\\#{$1}" } #remove markers on markdown chars to not markdown inside links
      else
        res = %{<a target="_blank" href="#{captures[1]}://#{captures[2]}">#{captures[2]}</a>}
        res.gsub!(/(\*|_)/) { |m| "\\#{$1}" }
        res
      end
    end
    message
  end

  def process_emphasis(message)
    message.gsub!("\\**", "-^doublestar^-")
    message.gsub!("\\__", "-^doublescore^-")
    message.gsub!("\\*", "-^star^-")
    message.gsub!("\\_", "-^score^-")
    message.gsub!(/(\*\*\*|___)(.+?)\1/m, '<em><strong>\2</strong></em>')
    message.gsub!(/(\*\*|__)(.+?)\1/m, '<strong>\2</strong>')
    message.gsub!(/(\*|_)(.+?)\1/m, '<em>\2</em>')
    message.gsub!("-^doublestar^-", "**")
    message.gsub!("-^doublescore^-", "__")
    message.gsub!("-^star^-", "*")
    message.gsub!("-^score^-", "_")
    message
  end

  def process_vimeo(message, vimeo_maps)
    regex = /https?:\/\/(?:w{3}\.)?vimeo.com\/(\d{6,})/
    processed_message = message.gsub(regex) do |matched_string|
      match_data = message.match(regex)
      video_id = match_data[1]
      if vimeo_maps && vimeo_maps[video_id]
        title = h(CGI::unescape(vimeo_maps[video_id]))
      else
        title = I18n.t 'application.helper.video_title.unknown'
      end
      ' <a class="video-link" data-host="vimeo.com" data-video-id="' + video_id + '" href="' + match_data[0] + '" target="_blank">Vimeo: ' + title + '</a>'
    end
    processed_message
  end

  def process_emoticons(message)
    map = {
      "&lt;3" => "&hearts;",
      ":("    => "&#9785;",
      ":-("   => "&#9785;",
      ":)"    => "&#9786;",
      ":-)"   => "&#9786;",
      "-&gt;" => "&rarr;",
      "&lt;-" => "&larr;",
      "..."   => "&hellip;",
      "(tm)"  => "&trade;",
      "(r)"   => "&reg;",
      "(c)"   => "&copy;"
    }

    map.each do |search, replace|
      message.gsub!(search, replace)
    end
    message
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
    string.cleaned_is_rtl? ? 'rtl' : ''
  end

  def rtl?
    @rtl ||= RTL_LANGUAGES.include? I18n.locale
  end
end
