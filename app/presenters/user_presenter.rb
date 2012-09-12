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
      }
    ).to_json(options)
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
