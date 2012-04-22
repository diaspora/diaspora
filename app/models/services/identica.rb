require 'uri'

class Services::Identica < Service
  MAX_CHARACTERS = 140
  SHORTENED_URL_LENGTH = 21

  def provider
    "identica"
  end

  def post(post, url='')
    Rails.logger.debug("event=post_to_service type=identica sender_id=#{self.user_id}")
    message = public_message(post, url)

    configure_identica

    Identica.update(message)
  end


  def public_message(post, url)
    buffer_amt = 0
    URI.extract( post.text(:plain_text => true), ['http','https'] ) do |a_url|
      buffer_amt += (a_url.length - SHORTENED_URL_LENGTH)
    end

    super(post, MAX_CHARACTERS + buffer_amt,  url)
  end

  def profile_photo_url
    configure_identica

    Identica.profile_image(nickname, :size => "original")
  end

  private
  def configure_identica
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
  end
end
