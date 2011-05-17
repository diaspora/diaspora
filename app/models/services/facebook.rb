class Services::Facebook < Service
  MAX_CHARACTERS = 420

  def provider
    "facebook"
  end

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

  def finder(opts = {})
    Rails.logger.debug("event=friend_finder type=facebook sender_id=#{self.user_id}")
    if self.service_users.blank?
      self.save_friends
    else
      Resque.enqueue(Job::UpdateServiceUsers, self.id)
    end
    person = Person.arel_table

    query = self.service_users.scoped
    if opts[:local]
      query = query.joins(:person).where(person[:owner_id].not_eq(nil))
    elsif opts[:remote]
      query = query.joins(:person).where(person[:owner_id].eq(nil))
    end

    result = ServiceUser.connection.execute(query.to_sql).to_a
    fakes = result.map{|r| FakeServiceUser.new(r) }
  end

  def save_friends
    url = "https://graph.facebook.com/me/friends?fields[]=name&fields[]=picture&access_token=#{URI.escape(self.access_token)}"
    response = RestClient.get(url)
    data = JSON.parse(response.body)['data']
    data.each{ |p|
      ServiceUser.find_or_create_by_service_id_and_uid(:service_id => self.id, :name => p["name"],
                         :uid => p["id"], :photo_url => p["picture"])
    }
  end
end
