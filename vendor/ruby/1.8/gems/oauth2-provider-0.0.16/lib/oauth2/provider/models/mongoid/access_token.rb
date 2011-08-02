class OAuth2::Provider::Models::Mongoid::AccessToken
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include ::Mongoid::Document
      include OAuth2::Provider::Models::AccessToken

      field :access_token
      field :expires_at, :type => Time
      field :refresh_token

      referenced_in(:authorization,
        :class_name => OAuth2::Provider.authorization_class_name,
        :foreign_key => :oauth_authorization_id
      )

      referenced_in(:client,
        :class_name => OAuth2::Provider.client_class_name,
        :foreign_key => :oauth_client_id
      )

      before_save do
        self.client ||= authorization.client
      end
    end

    module ClassMethods
      def find_by_refresh_token(refresh_token)
        where(:refresh_token => refresh_token).first
      end

      def find_by_access_token(access_token)
        where(:access_token => access_token).first
      end
    end
  end

  include Behaviour
end