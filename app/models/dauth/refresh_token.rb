class Dauth::RefreshToken < ActiveRecord::Base

  serialize :scopes, Array

  belongs_to :user
  belongs_to :app, :class_name => 'Dauth::ThirdpartyApp'
  has_many :access_tokens, :class_name => 'Dauth::AccessToken'

  attr_accessible :scopes,
                  :secret,
                  :token

  validates :token,  presence: true, uniqueness: true
  validates :app_id,  presence: true
  validates :scopes,  presence: true
  validates :user_id,  presence: true
  validates :secret,  presence: true

  before_validation :generate_token, :on => :create
  before_validation :generate_secret, :on => :create

  private

  def generate_token
    self.token = Digest::MD5.hexdigest "#{SecureRandom.hex(10)}-#{DateTime.now.to_s}"
  end

  def generate_secret
    self.secret = Digest::MD5.hexdigest "#{SecureRandom.hex(10)}-#{DateTime.now.to_s}"
  end
end