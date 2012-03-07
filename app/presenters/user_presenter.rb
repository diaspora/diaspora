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
        :aspects => aspects
      }
    ).to_json(options)
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