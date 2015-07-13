class RefreshToken < ActiveRecord::Base
  belongs_to :token

  before_validation :setup, on: :create

  validates :refresh_token, presence: true, uniqueness: true

  attr_reader :refresh_token

  def setup
    self.refresh_token = SecureRandom.hex(32)
    # No expipration date for now
  end

  # Finds the requested refresh token and destroys it if found; returns true if found, false otherwise
  def valid?(token)
    the_token = RefreshToken.find_by_refresh_token token
    if the_token
      RefreshToken.destroy_all refresh_token: the_token.refresh_token
      Token.destroy_all refresh_token: the_token.refresh_token
      true
    else
      false
    end
  end
end
