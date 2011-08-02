class OAuth2::Provider::Models::Mongoid::AuthorizationCode
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include ::Mongoid::Document
      include OAuth2::Provider::Models::AuthorizationCode

      field :code
      field :expires_at, :type => Time

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
      def find_by_code_and_redirect_uri(code, redirect_uri)
        where(:code => code, :redirect_uri => redirect_uri).first
      end

      def find_by_id(id)
        where(:id => id).first
      end

      def find_by_code(code)
        where(:code => code).first
      end
    end
  end

  include Behaviour
end