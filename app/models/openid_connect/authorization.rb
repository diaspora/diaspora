class OpenidConnect::Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :o_auth_application

  validates :user, presence: true, uniqueness: true
  validates :o_auth_application, presence: true, uniqueness: true

  has_many :scopes, through: :authorization_scopes
  has_many :o_auth_access_tokens, dependent: :destroy
  has_many :id_tokens

  def generate_refresh_token
    self.refresh_token = SecureRandom.hex(32)
  end

  def create_access_token
    o_auth_access_tokens.create!.bearer_token
  end

  def self.find_by_client_id_and_user(client_id, user)
    app = OpenidConnect::OAuthApplication.find_by(client_id: client_id)
    find_by(o_auth_application: app, user: user)
  end

  def self.find_by_app_and_user(app, user)
    find_by(o_auth_application: app, user: user)
  end

  # TODO: Handle creation error
  def self.find_or_create(client_id, user)
    app = OpenidConnect::OAuthApplication.find_by(client_id: client_id)
    find_by_app_and_user(app, user) || create!(user: user, o_auth_application: app)
  end

  # TODO: Consider splitting into subclasses by flow type
end
