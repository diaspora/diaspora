class OAuthApplication < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :client_id, presence: true, uniqueness: true
  validates :client_secret, presence: true

  has_many :tokens
end
