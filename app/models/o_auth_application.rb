class OAuthApplication < ActiveRecord::Base
  belongs_to :user

  validates :client_id, presence: true, uniqueness: true
  validates :client_secret, presence: true

end
