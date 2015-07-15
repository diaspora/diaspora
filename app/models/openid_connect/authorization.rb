class OpenidConnect::Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :o_auth_application

  has_many :scopes, through: :authorization_scopes
  has_many :o_auth_access_tokens

  before_validation :setup, on: :create

  validates :refresh_token, presence: true, uniqueness: true
  validates :user, presence: true, uniqueness: true
  validates :o_auth_application, presence: true, uniqueness: true

  def setup
    self.refresh_token = SecureRandom.hex(32)
  end

  def create_access_token
    OpenidConnect::OAuthAccessToken.create!(authorization: self).bearer_token
  end

  # TODO: Actually call this method from token endpoint
  def regenerate_refresh_token
    self.refresh_token = SecureRandom.hex(32)
  end

  def self.find_by_client_id_and_user(app, user)
    find_by(o_auth_application: app, user: user)
  end

  # TODO: Handle creation error
  def self.find_or_create(client_id, user)
    app = OpenidConnect::OAuthApplication.find_by(client_id: client_id)
    find_by_client_id_and_user(app, user) || create!(user: user, o_auth_application: app)
  end

  # TODO: Incomplete class
end
