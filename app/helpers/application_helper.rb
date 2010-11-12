#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ApplicationHelper
  @@youtube_title_cache = Hash.new("no-title")

  def current_aspect?(aspect)
    !@aspect.is_a?(Symbol) && @aspect.id == aspect.id
  end

  def aspect_or_all_path aspect
    if @aspect.is_a? Aspect
      aspect_path @aspect
    else
      aspects_path
    end
  end
  
  def object_path(object, opts = {})
    object = object.person if object.is_a? User
    eval("#{object.class.to_s.underscore}_path(object, opts)")
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
    "#{time_ago_in_words(obj.created_at)} #{t('ago')}"
  end

  def person_url(person)
    case person.class.to_s
    when "User"
      user_path(person)
    when "Person"
      person_path(person)
    else
      I18n.t('application.helper.unknown_person')
    end
  end

  def owner_image_tag
    person_image_tag(current_user.person)
  end

  def owner_image_link
    person_image_link(current_user.person)
  end

  def person_image_tag(person)
    image_tag image_or_default(person), :class => "avatar", :alt => person.real_name, :title => person.real_name, "data-person_id" => person.id
  end

  def image_or_default(person)
    image_location = person.profile.image_url
    image_location ||= "/images/user/default.png"
    image_location
  end
  
  def hard_link(string, path)
    link_to string, path, :rel => 'external' 
  end

  def person_image_link(person, opts = {})
    if opts[:to] == :photos
      link_to person_image_tag(person), person_photos_path(person)
    else
      link_to person_image_tag(person), object_path(person)
    end
  end

  def new_request(request_count)
    "new_requests" if request_count > 0 #Should not be Il8ned
  end

  def post_yield_tag(post)
    (':' + post.id.to_s).to_sym
  end

  def person_photos_path person
    person_id = person.id if person.respond_to?(:id)
    person_id ||= person
      
    "#{photos_path}?person_id=#{person_id}"
  end

  def markdownify(message, options = {})
    message = h(message).html_safe

    [:autolinks, :youtube, :emphasis, :links].each do |k|
      if !options.has_key?(k)
        options[k] = true
      end
    end

    if options[:links]
      message.gsub!(/\[([^\[]+)\]\(([^ ]+) \&quot;(([^&]|(&[^q])|(&q[^u])|(&qu[^o])|(&quo[^t])|(&quot[^;]))+)\&quot;\)/) do |m|
        escape = (options[:emphasis]) ? "\\" : ""
        res = "<a target=\"#{escape}_blank\" href=\"#{$2}\" title=\"#{$3}\">#{$1}</a>"
        res
      end
      message.gsub!(/\[([^\[]+)\]\(([^ ]+)\)/) do |m|
        escape = (options[:emphasis]) ? "\\" : ""
        res = "<a target=\"#{escape}_blank\" href=\"#{$2}\">#{$1}</a>"
        res
      end
    end

    if options[:youtube]
      message.gsub!(/( |^)(http:\/\/)?www\.youtube\.com\/watch[^ ]*v=([A-Za-z0-9_]+)(&[^ ]*|)/) do |m|
        res = "#{$1}youtube.com::#{$3}"
        res.gsub!(/(\*|_)/) { |m| "\\#{$1}" } if options[:emphasis]
        res
      end
    end

    if options[:autolinks]
      message.gsub!(/( |^)(www\.[^ ]+\.[^ ])/, '\1http://\2')
      message.gsub!(/(<a target="\\?_blank" href=")?(https|http|ftp):\/\/([^ ]+)/) do |m|
        if !$1.nil?
          m
        else
          res = %{<a target="_blank" href="#{$2}://#{$3}">#{$3}</a>}
          res.gsub!(/(\*|_)/) { |m| "\\#{$1}" } if options[:emphasis]
          res
        end
      end
    end

    if options[:emphasis]
      message.gsub!(/([^\\]|^)\*\*(([^*]|([^*]\*[^*]))*[^*\\])\*\*/, '\1<strong>\2</strong>')
      message.gsub!(/([^\\]|^)__(([^_]|([^_]_[^_]))*[^_\\])__/, '\1<strong>\2</strong>')
      message.gsub!(/([^\\]|^)\*([^*]*[^\\])\*/, '\1<em>\2</em>')
      message.gsub!(/([^\\]|^)_([^_]*[^\\])_/, '\1<em>\2</em>')
      message.gsub!(/([^\\]|^)\*/, '\1')
      message.gsub!(/([^\\]|^)_/, '\1')
      message.gsub!("\\*", "*")
      message.gsub!("\\_", "_")
    end

    if options[:youtube]
      while youtube = message.match(/youtube\.com::([A-Za-z0-9_\\]+)/)
        videoid = youtube[1]
        message.gsub!('youtube.com::'+videoid, '<a onclick="openVideo(\'youtube.com\', \'' + videoid + '\', this)" href="#video">Youtube: ' + youtube_title(videoid) + '</a>')
      end
    end

    return message
  end

  def youtube_title(id)
    unless @@youtube_title_cache[id] == 'no-title'
      return @@youtube_title_cache[id]
    end

    ret = I18n.t 'application.helper.youtube_title.unknown'
    http = Net::HTTP.new('gdata.youtube.com', 80)
    path = '/feeds/api/videos/'+id+'?v=2'
    resp, data = http.get(path, nil)
    title = data.match(/<title>(.*)<\/title>/)
    unless title.nil?
      ret = title.to_s[7..-9]
    end

    @@youtube_title_cache[id] = ret;
    return ret
  end
end
