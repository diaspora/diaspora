#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module StatusMessagesHelper
  @@youtube_title_cache = Hash.new("no-title")

  def my_latest_message
    unless @latest_status_message.nil?
      return @latest_status_message.message
    else
      return I18n.t('status_messages.helper.no_message_to_display')
    end
  end

  def make_links(message)
    # If there should be some kind of bb-style markup, email/diaspora highlighting, it could go here.
    
    # next line is important due to XSS! (h is rail's make_html_safe-function)
    message = h(message).html_safe

    message.gsub!(/( |^)(www\.[^ ]+\.[^ ])/) do |m|
      res = "#{$1}http://#{$2}"
      res.gsub!(/^(\*|_)$/) { |m| "\\#{$1}" }
      res
    end
    message.gsub!(/( |^)http:\/\/www\.youtube\.com\/watch[^ ]*v=([A-Za-z0-9_]+)(&[^ ]*|)/) do |m|
      res = "#{$1}youtube.com::#{$2}"
      res.gsub!(/(\*|_)/) { |m| "\\#{$1}" }
      res
    end
    message.gsub!(/(https|http|ftp):\/\/([^ ]+)/) do |m|
      res = %{<a target="_blank" href="#{$1}://#{$2}">#{$2}</a>}
      res.gsub!(/(\*|_)/) { |m| "\\#{$1}" }
      res
    end

    # markdown
    message.gsub!(/([^\\]|^)\*\*(([^*]|([^*]\*[^*]))*[^\\])\*\*/, '\1<strong>\2</strong>')
    message.gsub!(/([^\\]|^)__(([^_]|([^_]_[^_]))*[^\\])__/, '\1<strong>\2</strong>')
    message.gsub!(/([^\\]|^)\*([^*]*[^\\])\*/, '\1<em>\2</em>')
    message.gsub!(/([^\\]|^)_([^_]*[^\\])_/, '\1<em>\2</em>')
    message.gsub!(/([^\\]|^)\*/, '\1')
    message.gsub!(/([^\\]|^)_/, '\1')
    message.gsub!("\\*", "*")
    message.gsub!("\\_", "_")

    while youtube = message.match(/youtube\.com::([A-Za-z0-9_\\]+)/)
      videoid = youtube[1]
      message.gsub!('youtube.com::'+videoid, '<a onclick="openVideo(\'youtube.com\', \'' + videoid + '\', this)" href="#video">Youtube: ' + youtube_title(videoid) + '</a>')
    end

    return message
  end

  def youtube_title(id)
    unless @@youtube_title_cache[id] == 'no-title'
      return @@youtube_title_cache[id]
    end

    ret = 'Unknown Video Title' #TODO add translation
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
