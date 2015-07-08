class OAuthApplication < ActiveRecord::Base
  belongs_to :user

  has_many :authorizations

  validates :client_id, presence: true, uniqueness: true
  validates :client_secret, presence: true

  before_validation :setup, on: :create
  def setup
    self.client_id = SecureRandom.hex(16)
    self.client_secret = SecureRandom.hex(32)
  end

  class << self
    def register!(registrarHash)
      registrarHash.validate!
      buildClientApplication(registrarHash)
    end

    def buildClientApplication(registrarHash)
      client = OAuthApplication.create!
      client.attributes = filterNilValues(registrarHash)
      client.save!
      client
    end

    def filterNilValues(registrarHash)
      {
        name: registrarHash.client_name,
        redirect_uris: registrarHash.redirect_uris
      }.delete_if do |key, value|
        value.nil?
      end
    end
  end
end
