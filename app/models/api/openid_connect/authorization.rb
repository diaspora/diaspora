module Api
  module OpenidConnect
    class Authorization < ActiveRecord::Base
      belongs_to :user
      belongs_to :o_auth_application

      validates :user, presence: true
      validates :o_auth_application, presence: true
      validates :user, uniqueness: {scope: :o_auth_application}
      validate :validate_scope_names
      serialize :scopes, JSON

      has_many :o_auth_access_tokens, dependent: :destroy
      has_many :id_tokens, dependent: :destroy

      before_validation :setup, on: :create

      scope :with_redirect_uri, ->(given_uri) { where redirect_uri: given_uri }

      SCOPES = %w(openid read write)

      def setup
        self.refresh_token = SecureRandom.hex(32)
      end

      def validate_scope_names
        return unless scopes
        scopes.each do |scope|
          errors.add(:scope, "is not a valid scope name") unless SCOPES.include? scope
        end
      end

      def accessible?(required_scopes=nil)
        Array(required_scopes).all? { |required_scope|
          scopes.include? required_scope
        }
      end

      def create_code
        SecureRandom.hex(32).tap do |code|
          self.code = code
          save
        end
      end

      def create_access_token
        o_auth_access_tokens.create!.bearer_token
      end

      def create_id_token
        id_tokens.create!(nonce: nonce)
      end

      def self.find_by_client_id_and_user(client_id, user)
        app = Api::OpenidConnect::OAuthApplication.find_by(client_id: client_id)
        find_by(o_auth_application: app, user: user)
      end

      def self.find_by_refresh_token(client_id, refresh_token)
        Api::OpenidConnect::Authorization.joins(:o_auth_application).find_by(
          o_auth_applications: {client_id: client_id}, refresh_token: refresh_token)
      end

      def self.use_code(code)
        return unless code
        find_by(code: code).tap do |auth|
          next unless auth
          auth.code = nil
          auth.save
        end
      end
    end
  end
end
