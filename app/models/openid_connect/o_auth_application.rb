class OpenidConnect::OAuthApplication < ActiveRecord::Base
  has_many :authorizations
  has_many :user, through: :authorizations

  validates :client_id, presence: true, uniqueness: true
  validates :client_secret, presence: true
  validates :client_name, presence: true

  serialize :redirect_uris, JSON
  serialize :response_types, JSON
  serialize :grant_types, JSON
  serialize :contacts, JSON

  before_validation :setup, on: :create

  def setup
    self.client_id = SecureRandom.hex(16)
    self.client_secret = SecureRandom.hex(32)
    self.response_types = []
    self.grant_types = []
    self.application_type = "web"
    self.contacts = []
    self.logo_uri = ""
    self.client_uri = ""
    self.policy_uri = ""
    self.tos_uri = ""
  end

  class << self
    def available_response_types
      ["id_token", "id_token token"]
    end

    def register!(registrar)
      registrar.validate!
      build_client_application(registrar)
    end

    private

    def build_client_application(registrar)
      create! registrar_attributes(registrar)
    end

    def supported_metadata
      %i(client_name response_types grant_types application_type
         contacts logo_uri client_uri policy_uri tos_uri redirect_uris)
    end

    def registrar_attributes(registrar)
      supported_metadata.each_with_object({}) do |key, attr|
        if registrar.public_send(key)
          attr[key] = registrar.public_send(key)
        end
      end
    end
  end
end
