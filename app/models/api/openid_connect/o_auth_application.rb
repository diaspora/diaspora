module Api
  module OpenidConnect
    class OAuthApplication < ActiveRecord::Base
      has_many :authorizations, dependent: :destroy
      has_many :user, through: :authorizations

      validates :client_id, presence: true, uniqueness: true
      validates :client_secret, presence: true
      validates :client_name, presence: true

      %i(redirect_uris response_types grant_types contacts).each do |serializable|
        serialize serializable, JSON
      end

      before_validation :setup, on: :create

      def setup
        self.client_id = SecureRandom.hex(16)
        self.client_secret = SecureRandom.hex(32)
      end

      def image_uri
        logo_uri ? Diaspora::Camo.image_url(logo_uri) : nil
      end

      class << self
        def available_response_types
          ["id_token", "id_token token", "code"]
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
             contacts logo_uri client_uri policy_uri tos_uri redirect_uris
             sector_identifier_uri subject_type)
        end

        def registrar_attributes(registrar)
          supported_metadata.each_with_object({}) do |key, attr|
            value = registrar.public_send(key)
            next unless value
            if key == :subject_type
              attr[:ppid] = (value == "pairwise")
            else
              attr[key] = value
            end
          end
        end
      end
    end
  end
end
