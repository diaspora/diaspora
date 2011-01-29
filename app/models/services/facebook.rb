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

  def finder
    Rails.logger.debug("event=friend_finder type=facebook sender_id=#{self.user_id}")
    response = RestClient.get("https://graph.facebook.com/me/friends", {:params => {:access_token => self.access_token}})
    data = JSON.parse(response.body)['data']

    data_h = {}
    data.each do |d|
      data_h[d['id']] = {:name => d['name']}
    end

    invitation_objects = Invitation.joins(:recipient).where(:sender_id => self.user_id,
                                                            :users => {:invitation_service => 'facebook',
                                                                       :invitation_identifier => data_h.keys})

    invitation_objects.each do |inv|
      data_h[inv.recipient.invitation_identifier][:invitation_id] = inv.id
    end

    service_objects = Services::Facebook.where(:uid => data_h.keys).includes(:user => {:person => :profile})
    person_ids_and_uids = {}

    service_objects.each do |s|
      data_h[s.uid][:person] = s.user.person if s.user.person.profile.searchable
      person_ids_and_uids[s.user.person.id] = s.uid
    end

    contact_objects = self.user.contacts.where(:person_id => person_ids_and_uids.keys)
    contact_objects.each{|c| data_h[person_ids_and_uids[c.person_id]][:contact] = c}

    data_h
  end
end
