#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module MarkdownifyHelper
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
    message.gsub!(/\[\s*([^\[]+?)\s*\]\(\s*([^ ]+\s*) \&quot;(([^&]|(&[^q])|(&q[^u])|(&qu[^o])|(&quo[^t])|(&quot[^;]))+)\&quot;\s*\)/) do |m|
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

    message.gsub!(/\[\s*([^\[]+?)\s*\]\(\s*([^ ]+)\s*\)/) do |m|
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
      elsif m.match(/(youtu.?be|vimeo)/)
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
    regex = /https?:\/\/(?:w{3}\.)?vimeo.com\/(\d{6,})\/?/
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
end
