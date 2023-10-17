# frozen_string_literal: true

class NotificationSettingsService
  def initialize(user)
    @user = user
  end

  def email_disabled?(notification_type)
    !email_enabled?(notification_type)
  end

  def email_enabled?(notification_type)
    notification_enabled?(notification_type, :email_enabled?)
  end

  def in_app_disabled?(notfication_type)
    !in_app_enabled?(notfication_type)
  end

  def in_app_enabled?(notification_type)
    notification_enabled?(notification_type, :in_app_enabled?)
  end

  private

  attr_reader :user

  delegate :user_preferences, to: :user

  def notification_enabled?(notification_type, pref_method)
    pref = user_preferences.find_by(email_type: notification_type)
    return true if pref.nil?

    pref.public_send pref_method
  end
end
