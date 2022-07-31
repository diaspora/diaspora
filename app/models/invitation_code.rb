# frozen_string_literal: true

class InvitationCode < ApplicationRecord
  belongs_to :user

  before_create :generate_token, :set_default_invite_count

  delegate :name, to: :user, prefix: true

  def to_param
    token
  end

  def can_be_used?
    count > 0 && AppConfig.settings.invitations.open?
  end

  def add_invites!
    update(count: count + 100)
  end

  def use!
    update(count: count - 1)
  end

  def generate_token
    loop do
      self.token = SecureRandom.hex(6)
      break unless InvitationCode.default_scoped.exists?(token: token)
    end
  end

  def self.default_inviter_or(user)
    if AppConfig.admins.account.present?
      inviter = User.find_by_username(AppConfig.admins.account.get)
    end
    inviter ||= user
    inviter
  end

  def set_default_invite_count
    self.count = AppConfig['settings.invitations.count'] || 25
  end
end
