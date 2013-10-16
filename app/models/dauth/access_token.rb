class Dauth::AccessToken < ActiveRecord::Base
  belongs_to :refresh_token, class_name: 'Dauth::RefreshToken'

  attr_accessible :token,
                  :secret,
                  :expire_at

  validates :refresh_token_id, presence: true
  validates :token, presence: true, uniqueness: true
  validates :secret, presence: true

  before_validation :generate_token, :on => :create
  before_validation :generate_secret, :on => :create
  before_validation :generate_expire_time, :on => :create

  def expire?
    self.expire_at < Time.now
  end

  private

  def generate_token
    self.token = Digest::MD5.hexdigest "#{SecureRandom.hex(10)}-#{DateTime.now.to_s}"
  end

  def generate_secret
    self.secret = Digest::MD5.hexdigest "#{SecureRandom.hex(10)}-#{DateTime.now.to_s}"
  end

  def generate_expire_time
    self.expire_at = Time.now+1.month
  end
end
