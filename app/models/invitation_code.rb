class InvitationCode < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user

  before_create :generate_token

  def to_param
    token 
  end

  def generate_token
    begin
      self.token = ActiveSupport::SecureRandom.hex(6)
    end while InvitationCode.exists?(:token => self[:token])
  end
end
