class Services::Twitter < Service
  MAX_CHARACTERS = 140
  SHORTENED_URL_LENGTH = 21

  def provider
    "twitter"
  end

  def post(post, url='')
    Rails.logger.debug("event=post_to_service type=twitter sender_id=#{self.user_id}")
    message = public_message(post, url)
    tweet = client.update(message)
    post.tweet_id = tweet.id
    post.save
  end


  def public_message(post, url)
    buffer_amt = 0
    URI.extract( post.text(:plain_text => true), ['http','https'] ) do |a_url|
      buffer_amt += (a_url.length - SHORTENED_URL_LENGTH)
    end

    #if photos, always include url, otherwise not for short posts
    super(post, MAX_CHARACTERS + buffer_amt,  url, post.photos.any?)
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
