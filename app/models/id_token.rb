class IdToken < ActiveRecord::Base
  belongs_to :user
  belongs_to :o_auth_application

  before_validation :setup, on: :create

  validates :user, presence: true
  validates :o_auth_application, presence: true

  default_scope -> { where("expires_at >= ?", Time.now.utc) }

  def setup
    self.expires_at = 30.minutes.from_now
  end

  def to_jwt(options = {})
    to_response_object(options).to_jwt OpenidConnect::IdTokenConfig.private_key
  end

  def to_response_object(options = {})
    claims = {
      iss: AppConfig.environment.url,
      sub: AppConfig.environment.url + o_auth_application.client_id.to_s + user.id.to_s, # TODO: Convert to proper PPID
      aud: o_auth_application.client_id,
      exp: expires_at.to_i,
      iat: created_at.to_i,
      auth_time: user.current_sign_in_at.to_i,
      nonce: nonce,
      acr: 0 # TODO: Adjust ?
    }
    id_token = OpenIDConnect::ResponseObject::IdToken.new(claims)
    id_token.code = options[:code] if options[:code]
    id_token.access_token = options[:access_token] if options[:access_token]
    id_token
  end

  # TODO: Add support for request objects
end
