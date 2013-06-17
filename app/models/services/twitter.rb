class Services::Twitter < Service
  include ActionView::Helpers::TextHelper
  include MarkdownifyHelper

  MAX_CHARACTERS = 140
  SHORTENED_URL_LENGTH = 21

  def provider
    "twitter"
  end

  def post(post, url='')
    Rails.logger.debug("event=post_to_service type=twitter sender_id=#{self.user_id}")
    (0...20).each do |retry_count|
      begin
        message = build_twitter_post(post, url, retry_count)
        @tweet = client.update(message)
        break
      rescue Twitter::Error::Forbidden => e
        if e.message != 'Status is over 140 characters' || retry_count == 20
          raise e
        end
      end
    end
    post.tweet_id = @tweet.id
    post.save
  end

  def adjust_length_for_urls(post_text)
    real_length = post_text.length
    URI.extract( post_text, ['http','https'] ) do |a_url|
      # add or subtract from real length - urls for tweets are always 
      # shortened to SHORTENED_URL_LENGTH
      if a_url.length >= SHORTENED_URL_LENGTH
        real_length -= a_url.length - SHORTENED_URL_LENGTH
      else
        real_length += SHORTENED_URL_LENGTH - a_url.length 
      end
    end
    return real_length
  end

  def add_post_link(post, post_text, maxchars)
    post_url = Rails.application.routes.url_helpers.short_post_url(
      post, 
      :protocol => AppConfig.pod_uri.scheme, 
      :host => AppConfig.pod_uri.authority
    )
    truncated = truncate(post_text, :length => (maxchars - (SHORTENED_URL_LENGTH+1) ))
    post_text = "#{truncated} #{post_url}"
  end

  def build_twitter_post(post, url, retry_count=0)
    maxchars = MAX_CHARACTERS - retry_count*5
    post_text = strip_markdown(post.text(:plain_text => true))
    #if photos, always include url, otherwise not for short posts
    if adjust_length_for_urls(post_text) > maxchars || post.photos.any?
      post_text = add_post_link(post, post_text, maxchars)
    end
    return post_text
  end

  def profile_photo_url
    client.user(nickname).profile_image_url_https("original")
  end

  def delete_post(post)
    if post.present? && post.tweet_id.present?
      Rails.logger.debug("event=delete_from_service type=twitter sender_id=#{self.user_id}")
      delete_from_twitter(post.tweet_id)
    end
  end

  def delete_from_twitter(service_post_id)
    client.status_destroy(service_post_id)
  end

  private
  def client
    @client ||= Twitter::Client.new(
      oauth_token: self.access_token,
      oauth_token_secret: self.access_secret
    )
  end
end
