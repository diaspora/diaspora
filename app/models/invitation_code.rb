class InvitationCode < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user

  before_create :generate_token, :set_default_invite_count

  def to_param
    token 
  end

  def add_invites!
    self.update_attributes(:count => self.count+100)
  end

  def use!
    self.update_attributes(:count => self.count-1)
  end

  def generate_token
    begin
      self.token = ActiveSupport::SecureRandom.hex(6)
    end while InvitationCode.exists?(:token => self[:token])
  end

  def self.default_inviter_or(user)
    if AppConfig[:admin_account].present?
      inviter = User.find_by_username(AppConfig[:admin_account])
    end
    inviter ||= user
    inviter
  end

  def set_default_invite_count
    self.count = AppConfig[:invite_count] || 25
  end
end