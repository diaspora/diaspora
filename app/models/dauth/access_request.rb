class Dauth::AccessRequest < ActiveRecord::Base
  serialize :scopes, Array

  attr_accessible :auth_token,
                  :callback_url,
                  :dev_handle,
                  :scopes,
                  :app_id,
                  :app_name,
                  :app_description,
                  :app_version,
                  :redirect_url

  validates :auth_token,  presence: true, uniqueness: true
  validates :callback_url,  presence: true
  validates :dev_handle, presence: true
  validates :app_id, presence: true
  validates :redirect_url, presence: true 
  validates :scopes,  presence: true

  before_validation :generate_auth_token, :on => :create

  def generate_auth_token
    self.auth_token = Digest::MD5.hexdigest "#{SecureRandom.hex(10)}-#{DateTime.now.to_s}"
  end
end
