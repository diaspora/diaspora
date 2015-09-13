class OpenidConnect::Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :o_auth_application
  has_many :scopes, through: :authorization_scopes
  has_many :o_auth_access_tokens

  before_validation :setup, on: :create

  validates :refresh_token, uniqueness: true
  validates :user, :o_auth_application, uniqueness: true

  # TODO: Incomplete class

  def setup
    self.refresh_token = nil
  end

  def self.valid?(token)
    OpenidConnect::Authorization.exists? refresh_token: token
  end

  def create_refresh_token
    self.refresh_token = SecureRandom.hex(32)
  end

  def create_token
    o_auth_access_tokens.create!.bearer_token
  end

  def self.find_by_client_id_and_user(client_id, user)
    app = OpenidConnect::OAuthApplication.find_by(client_id: client_id)
    find_by(o_auth_application: app, user: user)
  end

  def self.find_or_create(client_id, user)
    auth = find_by_client_id_and_user client_id, user
    unless auth
      # TODO: Handle creation error
      auth = create! user: user, o_auth_application: OpenidConnect::OAuthApplication.find_by(client_id: client_id)
    end
    auth
  end
end
