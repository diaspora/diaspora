module Api
  module OpenidConnect
    class Authorization < ActiveRecord::Base
      belongs_to :user
      belongs_to :o_auth_application

      validates :user, presence: true
      validates :o_auth_application, presence: true
      validates :user, uniqueness: {scope: :o_auth_application}

      has_many :authorization_scopes
      has_many :scopes, through: :authorization_scopes
      has_many :o_auth_access_tokens, dependent: :destroy
      has_many :id_tokens, dependent: :destroy

      before_validation :setup, on: :create

      scope :with_redirect_uri, ->(given_uri) { where redirect_uri: given_uri }

      def setup
        self.refresh_token = SecureRandom.hex(32)
      end

      def accessible?(required_scopes=nil)
        Array(required_scopes).all? do |required_scope|
          scopes.include? required_scope
        end
      end

      def create_code
        self.code = SecureRandom.hex(32)
        save
        code
      end

      def create_access_token
        o_auth_access_tokens.create!.bearer_token
        # TODO: Add support for request object
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
        auth = find_by(code: code)
        auth.code = nil if auth # Remove auth code if found so it can't be reused
        auth
      end
    end
  end
end
