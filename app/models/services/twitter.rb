class Services::Twitter < Service
  MAX_CHARACTERS = 140
  SHORTENED_URL_LENGTH = 21

  def provider
    "twitter"
  end

  def post(post, url='')
    Rails.logger.debug("event=post_to_service type=twitter sender_id=#{self.user_id}")
    message = public_message(post, url)

    client.update(message)
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

  private
  def client
    @client ||= Twitter::Client.new(
      oauth_token: self.access_token,
      oauth_token_secret: self.access_secret
    )
  end
end
