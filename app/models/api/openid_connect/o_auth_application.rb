require "digest"

module Api
  module OpenidConnect
    class OAuthApplication < ActiveRecord::Base
      has_many :authorizations, dependent: :destroy
      has_many :user, through: :authorizations

      validates :client_id, presence: true, uniqueness: true
      validates :client_secret, presence: true
      validates :client_name, uniqueness: {scope: :redirect_uris}

      %i(redirect_uris response_types grant_types contacts).each do |serializable|
        serialize serializable, JSON
      end

      before_validation :setup, on: :create
      before_validation do
        redirect_uris.sort!
      end

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
          attributes = registrar_attributes(registrar)
          check_sector_identifier_uri(attributes)
          check_redirect_uris(attributes)
          create! attributes
        end

        def check_sector_identifier_uri(attributes)
          sector_identifier_uri = attributes[:sector_identifier_uri]
          return unless sector_identifier_uri
          uri = URI.parse(sector_identifier_uri)
          response = Net::HTTP.get_response(uri)
          sector_identifier_uri_json = JSON.parse(response.body)
          redirect_uris = attributes[:redirect_uris]
          sector_identifier_uri_includes_redirect_uris = (redirect_uris - sector_identifier_uri_json).empty?
          return if sector_identifier_uri_includes_redirect_uris
          raise Api::OpenidConnect::Exception::InvalidSectorIdentifierUri.new
        end

        def check_redirect_uris(attributes)
          redirect_uris = attributes[:redirect_uris]
          uri_array = redirect_uris.map {|uri| URI(uri) }
          any_uri_contains_fragment = uri_array.any? {|uri| !uri.fragment.nil? }
          return unless any_uri_contains_fragment
          raise Api::OpenidConnect::Exception::InvalidRedirectUri.new
        end

        def supported_metadata
          %i(client_name response_types grant_types application_type
             contacts logo_uri client_uri policy_uri tos_uri redirect_uris
             sector_identifier_uri subject_type token_endpoint_auth_method jwks jwks_uri)
        end

        def registrar_attributes(registrar)
          supported_metadata.each_with_object({}) do |key, attr|
            value = registrar.public_send(key)
            next unless value
            if key == :subject_type
              attr[:ppid] = (value == "pairwise")
            elsif key == :jwks_uri
              uri = URI.parse(value)
              response = Net::HTTP.get_response(uri)
              file_name = create_file_path(response.body)
              attr[:jwks_file] = file_name + ".json"
              attr[:jwks_uri] = value
            elsif key == :jwks
              file_name = create_file_path(value.to_json)
              attr[:jwks_file] = file_name + ".json"
            else
              attr[key] = value
            end
          end
        end

        def create_file_path(content)
          file_name = Base64.urlsafe_encode64(Digest::SHA256.base64digest(content))
          directory_name = File.join(Rails.root, "config", "jwks")
          Dir.mkdir(directory_name) unless File.exist?(directory_name)
          jwk_file_path = File.join(Rails.root, "config", "jwks", file_name + ".json")
          File.write jwk_file_path, content
          File.chmod(0600, jwk_file_path)
          file_name
        end
      end
    end
  end
end
