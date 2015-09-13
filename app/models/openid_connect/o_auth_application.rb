class OpenidConnect::OAuthApplication < ActiveRecord::Base
  belongs_to :user

  has_many :authorizations
  has_many :user, through: :authorizations

  validates :client_id, presence: true, uniqueness: true
  validates :client_secret, presence: true

  serialize :redirect_uris, JSON

  before_validation :setup, on: :create

  def setup
    self.client_id = SecureRandom.hex(16)
    self.client_secret = SecureRandom.hex(32)
  end

  class << self
    def available_response_types
      ["id_token"]
    end

    def register!(registrar)
      registrar.validate!
      build_client_application(registrar)
    end

    def build_client_application(registrar)
      create! redirect_uris: registrar.redirect_uris
    end
  end
end
