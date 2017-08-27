# frozen_string_literal: true

class Services::Twitter < Service
  include Rails.application.routes.url_helpers

  MAX_CHARACTERS = 140
  SHORTENED_URL_LENGTH = 21
  LINK_PATTERN = %r{https?://\S+}

  def provider
    "twitter"
  end

  def post post, url=''
    logger.debug "event=post_to_service type=twitter sender_id=#{user_id} post=#{post.guid}"
    tweet = attempt_post post
    post.tweet_id = tweet.id
    post.save
  end

  def profile_photo_url
    client.user(nickname).profile_image_url_https "original"
  end

  def post_opts(post)
    {tweet_id: post.tweet_id} if post.tweet_id.present?
  end

  def delete_from_service(opts)
    logger.debug "event=delete_from_service type=twitter sender_id=#{user_id} tweet_id=#{opts[:tweet_id]}"
    delete_from_twitter(opts[:tweet_id])
  end

  private

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = AppConfig.services.twitter.key
      config.consumer_secret = AppConfig.services.twitter.secret
      config.access_token = access_token
      config.access_token_secret = access_secret
    end
  end

  def attempt_post post, retry_count=0
    message = build_twitter_post post, retry_count
    client.update message
  rescue Twitter::Error::Forbidden => e
    if ! e.message.include? 'is over 140' || retry_count == 20
      raise e
    else
      attempt_post post, retry_count+1
    end
  end

  def build_twitter_post post, retry_count=0
    max_characters = MAX_CHARACTERS - retry_count

    post_text = post.message.plain_text_without_markdown
    truncate_and_add_post_link post, post_text, max_characters
  end

  def truncate_and_add_post_link post, post_text, max_characters
    return post_text unless needs_link? post, post_text, max_characters

    post_url = short_post_url(
      post,
      protocol: AppConfig.pod_uri.scheme,
      host: AppConfig.pod_uri.authority
    )

    truncated_text = post_text.truncate max_characters - SHORTENED_URL_LENGTH + 1
    truncated_text = restore_truncated_url truncated_text, post_text, max_characters

    "#{truncated_text} #{post_url}"
  end

  def needs_link? post, post_text, max_characters
    adjust_length_for_urls(post_text) > max_characters || post.photos.any?
  end

  def adjust_length_for_urls post_text
    real_length = post_text.length

    URI.extract(post_text, ['http','https']) do |url|
      # add or subtract from real length - urls for tweets are always
      # shortened to SHORTENED_URL_LENGTH
      if url.length >= SHORTENED_URL_LENGTH
        real_length -= url.length - SHORTENED_URL_LENGTH
      else
        real_length += SHORTENED_URL_LENGTH - url.length
      end
    end

    real_length
  end

  def restore_truncated_url truncated_text, post_text, max_characters
    return truncated_text if truncated_text !~ /#{LINK_PATTERN}\Z/

    url = post_text.match(LINK_PATTERN, truncated_text.rindex('http'))[0]
    truncated_text = post_text.truncate(
      max_characters - SHORTENED_URL_LENGTH + 2,
      separator: ' ', omission: ''
    )

    "#{truncated_text} #{url} ..."
  end

  def delete_from_twitter service_post_id
    client.destroy_status service_post_id
  end
end
