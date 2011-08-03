class Services::Facebook < Service
  MAX_CHARACTERS = 420

  def provider
    "facebook"
  end

  def post(post, url='')
    Rails.logger.debug("event=post_to_service type=facebook sender_id=#{self.user_id}")
    message = public_message(post, url)
    begin
      Faraday.post("https://graph.facebook.com/me/feed", {:message => message, :access_token => self.access_token}.to_param)
    rescue Exception => e
      Rails.logger.info("#{e.message} failed to post to facebook")
    end
  end

  def public_message(post, url)
    super(post, MAX_CHARACTERS,  url)
  end

  def finder(opts = {})
    Rails.logger.debug("event=friend_finder type=facebook sender_id=#{self.user_id}")
    if self.service_users.blank?
      self.save_friends
      self.service_users.reload
    else
      Resque.enqueue(Job::UpdateServiceUsers, self.id)
    end
    person = Person.arel_table
    service_user = ServiceUser.arel_table
    if opts[:local]
      ServiceUser.joins(:person).where(:service_id => self.id).where(person[:owner_id].not_eq(nil)).order(:name).all
    elsif opts[:remote]
      ServiceUser.joins(:person).where(:service_id => self.id).where(person[:owner_id].eq(nil)).order(:name).all
    else
      self.service_users
    end
  end

  def save_friends
    url = "https://graph.facebook.com/me/friends?fields[]=name&fields[]=picture&access_token=#{URI.escape(self.access_token)}"
    response = Faraday.get(url)
    data = JSON.parse(response.body)['data']
    s_users = data.map{ |p|
      ServiceUser.new(:service_id => self.id, :uid => p["id"], :photo_url => p["picture"], :name => p["name"])
    }
    ServiceUser.import(s_users)
  end
end
