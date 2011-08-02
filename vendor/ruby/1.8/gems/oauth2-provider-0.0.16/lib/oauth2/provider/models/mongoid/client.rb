class OAuth2::Provider::Models::Mongoid::Client
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include ::Mongoid::Document
      include OAuth2::Provider::Models::Client

      field :oauth_secret
      field :oauth_identifier

      references_many(:authorizations,
        :class_name => OAuth2::Provider.authorization_class_name,
        :foreign_key => :oauth_client_id
      )

      references_many(:access_tokens,
        :class_name => OAuth2::Provider.access_token_class_name,
        :foreign_key => :oauth_client_id
      )

      references_many(:authorization_codes,
        :class_name => OAuth2::Provider.authorization_code_class_name,
        :foreign_key => :oauth_client_id
      )
    end

    module ClassMethods
      def find_by_oauth_identifier(identifier)
        where(:oauth_identifier => identifier).first
      end

      def find_by_oauth_identifier_and_oauth_secret(identifier, secret)
        where(:oauth_identifier => identifier, :oauth_secret => secret).first
      end
    end
  end

  include Behaviour
end