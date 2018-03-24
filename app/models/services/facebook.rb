# frozen_string_literal: true

class Services::Facebook < Service
  include Rails.application.routes.url_helpers

  OVERRIDE_FIELDS_ON_FB_UPDATE = [:contact_id, :person_id, :request_id, :invitation_id, :photo_url, :name, :username]
  MAX_CHARACTERS = 63206

  def provider
    "facebook"
  end

  def post(post, url='')
    logger.debug "event=post_to_service type=facebook sender_id=#{user_id} post=#{post.guid}"
    response = post_to_facebook("https://graph.facebook.com/me/feed", create_post_params(post).to_param)
    response = JSON.parse response.body
    post.facebook_id = response["id"]
    post.save
  end

  def post_to_facebook(url, body)
    Faraday.post(url, body)
  end

  def create_post_params(post)
    message = post.message.plain_text_without_markdown
    if post.photos.any?
      message += " " + short_post_url(post, protocol: AppConfig.pod_uri.scheme,
                                            host: AppConfig.pod_uri.authority)
    end

    {message: message,
     access_token: access_token,
     link:  post.message.urls.first
    }
  end

  def profile_photo_url
   "https://graph.facebook.com/#{self.uid}/picture?type=large&access_token=#{URI.escape(self.access_token)}"
  end

  def post_opts(post)
    {facebook_id: post.facebook_id} if post.facebook_id.present?
  end

  def delete_from_service(opts)
    logger.debug "event=delete_from_service type=facebook sender_id=#{user_id} facebook_id=#{opts[:facebook_id]}"
    delete_from_facebook("https://graph.facebook.com/#{opts[:facebook_id]}/", access_token: access_token)
  end

  def delete_from_facebook(url, body)
    Faraday.delete(url, body)
  end
end
