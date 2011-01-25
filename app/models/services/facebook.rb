class Services::Facebook < Service
  MAX_CHARACTERS = 420

  def post(post, url='')
    Rails.logger.debug("event=post_to_service type=facebook sender_id=#{self.user_id}")
    message = public_message(post, url)
    begin
      RestClient.post("https://graph.facebook.com/me/feed", :message => message, :access_token => self.access_token) 
    rescue Exception => e
      Rails.logger.info("#{e.message} failed to post to facebook")
    end
  end

  def public_message(post, url)
    super(post, MAX_CHARACTERS,  url)
  end

  def finder
    Rails.logger.debug("event=friend_finder type=facebook sender_id=#{self.user_id}")
    response = RestClient.get("https://graph.facebook.com/me/friends", {:params => {:access_token => self.access_token}})
    data = JSON.parse(response.body)['data']

    Hash[*data.collect {|v|
      [v['id'], {:name => v['name']}]
    }.flatten]
  end
end
