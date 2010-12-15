class Services::Identica < Service
  MAX_CHARACTERS = 140

  def post(post, url='')
    Rails.logger.debug("event=post_to_service type=Ostatus sender_id=#{self.user_id}")
    message = public_message(post, url)

    identica_key = SERVICES['identica']['consumer_key']
    identica_consumer_secret = SERVICES['identica']['consumer_secret']

    if identica_consumer_secret.blank? || identica_consumer_secret.blank?
      Rails.logger.info "you have a blank identica key or secret.... you should look into that"
    end

    Identica.configure do |config|
      config.consumer_key = identica_key
      config.consumer_secret = identica_consumer_secret
      config.oauth_token = self.access_token
      config.oauth_token_secret = self.access_secret
    end

    begin
      Identica.update(message)
    rescue Exception => e
      Rails.logger.info e.message
    end
  end

  def public_message(post, url)
    super(post, MAX_CHARACTERS,  url)
  end
end
