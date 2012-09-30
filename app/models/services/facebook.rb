require 'uri'
class Services::Facebook < Service
  include Rails.application.routes.url_helpers

  OVERRIDE_FIELDS_ON_FB_UPDATE = [:contact_id, :person_id, :request_id, :invitation_id, :photo_url, :name, :username]
  MAX_CHARACTERS = 420

  def provider
    "facebook"
  end

  def post(post, url='')
    Rails.logger.debug("event=post_to_service type=facebook sender_id=#{self.user_id}")
    if post.public?
      post_to_facebook("https://graph.facebook.com/me/joindiaspora:make", create_open_graph_params(post).to_param)
    else
      post_to_facebook("https://graph.facebook.com/me/feed", create_post_params(post).to_param)
    end
  end

  def post_to_facebook(url, body)
    Faraday.post(url, body)
  end

  def create_open_graph_params(post)
    {:post => "#{AppConfig.pod_uri.to_s}#{short_post_path(post)}", :access_token => self.access_token}
  end

  def create_post_params(post)
    message = post.text(:plain_text => true)
    {:message => message, :access_token => self.access_token, :link => URI.extract(message, ['https', 'http']).first}
  end

  def public_message(post, url)
    super(post, MAX_CHARACTERS, url)
  end

  def profile_photo_url
   "https://graph.facebook.com/#{self.uid}/picture?type=large&access_token=#{URI.escape(self.access_token)}"
 end
end
