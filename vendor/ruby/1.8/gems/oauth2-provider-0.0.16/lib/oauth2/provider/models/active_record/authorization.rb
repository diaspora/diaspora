class OAuth2::Provider::Models::ActiveRecord::Authorization < ActiveRecord::Base
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include OAuth2::Provider::Models::Authorization

      belongs_to :client, :class_name => OAuth2::Provider.client_class_name, :foreign_key => 'client_id'

      has_many :access_tokens, :class_name => OAuth2::Provider.access_token_class_name, :foreign_key => 'authorization_id'
      has_many :authorization_codes, :class_name => OAuth2::Provider.authorization_code_class_name, :foreign_key => 'authorization_id'
    end
  end

  include Behaviour
end