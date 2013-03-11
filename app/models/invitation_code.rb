class InvitationCode < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user

  before_create :generate_token, :set_default_invite_count

  delegate :name, to: :user, prefix: true
  
  def to_param
    token 
  end

  def can_be_used?
    self.count > 0
  end

  def add_invites!
    self.update_attributes(:count => self.count+100)
  end

  def use!
    self.update_attributes(:count => self.count-1)
  end

  def generate_token
    begin
      self.token = SecureRandom.hex(6)
    end while InvitationCode.exists?(:token => self[:token])
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
