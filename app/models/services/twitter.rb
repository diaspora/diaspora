class Services::Twitter < Service
  def post(message)
   Rails.logger.debug("event=post_to_service type=twitter sender_id=#{self.user_id}")

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
    
    Twitter.update(message)
  end
end
