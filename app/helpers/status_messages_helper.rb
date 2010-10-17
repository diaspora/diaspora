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
    message.gsub!(/( |^)(www\.[^ ]+\.[^ ])/, '\1http://\2')
    message.gsub!(/( |^)http:\/\/www\.youtube\.com\/watch[^ ]*v=([A-Za-z0-9_]+)(&[^ ]*|)/, '\1youtube.com::\2')
    message.gsub!(/(https|http|ftp):\/\/([^ ]+)/, '<a target="_blank" href="\1://\2">\2</a>')
   
    while youtube = message.match(/youtube\.com::([A-Za-z0-9_]+)/)
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
