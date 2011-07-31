module YoutubeTitles
  def self.included(model)
    model.class_eval do
      before_save do
        get_youtube_title text
      end
    end if model.respond_to?(:before_save)
  end

  def youtube_title_for video_id
    http = Net::HTTP.new('gdata.youtube.com', 80)
    path = "/feeds/api/videos/#{video_id}?v=2"
    resp, data = http.get(path, nil)
    title = data.match(/<title>(.*)<\/title>/)
    unless title.nil?
      title = title.to_s[7..-9]
    end
    title || I18n.t('application.helper.video_title.unknown')
  end

  def get_youtube_title text
    self.youtube_titles = {}
    youtube_match = text.enum_for(:scan, YOUTUBE_ID_REGEX).map { Regexp.last_match }
    return if youtube_match.empty?

    matches = {}
    youtube_match.each do |match_data|
      matches[match_data[1]] = CGI::escape(youtube_title_for(match_data[1]))
    end

    self.youtube_titles = matches unless matches.empty?
  end

  YOUTUBE_ID_REGEX = /(?:https?:\/\/)(?:youtu\.be\/|(?:[a-z]{2,3}\.)?youtube\.com\/watch(?:\?|#!|.+&|.+&amp;)v=)([\w-]{11})(?:\S*(#[^ ]+)|\S+)?/im unless defined? YOUTUBE_ID_REGEX
end
