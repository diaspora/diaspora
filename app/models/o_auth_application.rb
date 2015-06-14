class OAuthApplication < ActiveRecord::Base
  validates :client_id, presence: true, uniqueness: true
  validates :client_secret, presence: true

  has_many :tokens
end
