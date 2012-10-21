class UserPresenter
  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def to_json(options = {})
    self.user.person.as_api_response(:backbone).update(
      { :notifications_count => notifications_count,
        :unread_messages_count => unread_messages_count,
        :admin => admin,
        :aspects => aspects,
        :services => services,
        :following_count => self.user.contacts.receiving.count,
        :configured_services => self.configured_services,
        :key_ring => self.key_ring
      }
    ).to_json(options)
  end

  def key_ring
    unless self.user.person.key_ring == nil
      { "secured_decryption" => self.user.person.key_ring.secured_decryption,
        "secured_signing" => self.user.person.key_ring.secured_signing,
        "guid" => self.user.person.guid }
    end
  end
  
  def services
    ServicePresenter.as_collection(user.services)
  end

  def configured_services
    user.services.map{|service| service.provider }
  end

  def aspects
    AspectPresenter.as_collection(user.aspects)
  end

  def notifications_count
    @notification_count ||= user.unread_notifications.count
  end

  def unread_messages_count
    @unread_message_count ||= user.unread_message_count
  end

  def admin
    user.admin?
  end
end
