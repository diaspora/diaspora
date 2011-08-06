class Services::Twitter < Service
  MAX_CHARACTERS = 140

  def provider
    "twitter"
  end

  def post(post, url='')
    Rails.logger.debug("event=post_to_service type=twitter sender_id=#{self.user_id}")
    message = public_message(post, url)

    twitter_key = SERVICES['twitter']['consumer_key']
    twitter_consumer_secret = SERVICES['twitter']['consumer_secret']

    if twitter_consumer_secret.blank? || twitter_consumer_secret.blank?
      Rails.logger.info "you have a blank twitter key or secret.... you should look into that"
    end

    Twitter.configure do |config|
      config.consumer_key = twitter_key
      config.consumer_secret = twitter_consumer_secret
      config.oauth_token = self.access_token
      config.oauth_token_secret = self.access_secret
    end

    begin
      Twitter.update(message)
    rescue Exception => e
      Rails.logger.info e.message
    end
  end

  def public_message(post, url)
    super(post, MAX_CHARACTERS,  url)
  end
end
