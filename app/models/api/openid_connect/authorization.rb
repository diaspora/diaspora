# frozen_string_literal: true

# Inspired by https://github.com/nov/openid_connect_sample/blob/master/app/models/authorization.rb

module Api
  module OpenidConnect
    class Authorization < ApplicationRecord
      belongs_to :user
      belongs_to :o_auth_application

      validates :user, uniqueness: {scope: :o_auth_application}
      validate :validate_scope_names
      serialize :scopes, JSON

      has_many :o_auth_access_tokens, dependent: :destroy

      before_validation :setup, on: :create

      scope :with_redirect_uri, ->(given_uri) { where redirect_uri: given_uri }

      SCOPES = %w(openid sub aud name nickname profile picture read write)

      def setup
        self.refresh_token = SecureRandom.hex(32)
      end

      def validate_scope_names
        return unless scopes
        scopes.each do |scope|
          errors.add(:scope, "is not a valid scope name") unless SCOPES.include? scope
        end
      end

      # Inspired by https://github.com/nov/openid_connect_sample/blob/master/app/models/access_token.rb#L26
      def accessible?(required_scopes=nil)
        Array(required_scopes).all? { |required_scope|
          scopes.include? required_scope
        }
      end

      def create_code
        SecureRandom.hex(32).tap do |code|
          update!(code: code)
          update!(code_used: false)
        end
      end

      def create_access_token
        o_auth_access_tokens.create!.bearer_token
      end

      def create_id_token
        IdToken.new(self, nonce)
      end

      def self.find_by_client_id_user_and_scopes(client_id, user, scopes)
        app = Api::OpenidConnect::OAuthApplication.where(client_id: client_id)
        authorizations = where(o_auth_application: app, user: user).all
        authorizations.each do |authorization|
          if authorization.scopes.uniq.sort == Array(scopes).uniq.sort
            return authorization
          end
        end
        nil
      end

      def self.find_by_client_id_and_user(client_id, user)
        app = Api::OpenidConnect::OAuthApplication.where(client_id: client_id)
        find_by(o_auth_application: app, user: user)
      end

      def self.find_by_refresh_token(client_id, refresh_token)
        app = Api::OpenidConnect::OAuthApplication.where(client_id: client_id)
        find_by(o_auth_application: app, refresh_token: refresh_token)
      end

      def self.use_code(code)
        return unless code
        auth = find_by(code: code)
        return unless auth
        if auth.code_used
          auth.destroy
          nil
        else
          auth.update!(code_used: true)
          auth
        end
      end
    end
  end
end
