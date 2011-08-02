class OAuth2::Provider::Models::ActiveRecord::Client < ActiveRecord::Base
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include OAuth2::Provider::Models::Client

      has_many :authorizations, :class_name => OAuth2::Provider.authorization_class_name, :foreign_key => 'client_id'
      has_many :authorization_codes, :through => :authorizations, :class_name => OAuth2::Provider.authorization_code_class_name
      has_many :access_tokens, :through => :authorizations, :class_name => OAuth2::Provider.access_token_class_name
    end
  end

  include Behaviour
end