class OpenidConnect::Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :o_auth_application

  validates :user, presence: true
  validates :o_auth_application, presence: true

  has_many :scopes, through: :authorization_scopes
  has_many :o_auth_access_tokens, dependent: :destroy
  has_many :id_tokens, dependent: :destroy

  def generate_refresh_token
    self.refresh_token = SecureRandom.hex(32)
  end

  def create_access_token
    o_auth_access_tokens.create!.bearer_token
    # TODO: Add support for request object
  end

  def create_id_token(nonce)
    id_tokens.create!(nonce: nonce)
  end

  def self.find_by_client_id_and_user(client_id, user)
    app = OpenidConnect::OAuthApplication.find_by(client_id: client_id)
    find_by(o_auth_application: app, user: user)
  end

  # TODO: Consider splitting into subclasses by flow type
end
