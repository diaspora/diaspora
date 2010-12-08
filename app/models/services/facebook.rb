class Services::Facebook < Service
  def post(message)
    Rails.logger.debug("event=post_to_service type=facebook sender_id=#{self.user_id}")
    begin
      RestClient.post("https://graph.facebook.com/me/feed", :message => message, :access_token => self.access_token) 
    rescue Exception => e
      Rails.logger.info("#{e.message} failed to post to facebook")
    end
  end
end
