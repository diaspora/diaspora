class OAuth2::Provider::Models::ActiveRecord::AuthorizationCode < ActiveRecord::Base
  module Behaviour
    extend ActiveSupport::Concern

    included do
      include OAuth2::Provider::Models::AuthorizationCode

      belongs_to :authorization, :class_name => OAuth2::Provider.authorization_class_name, :foreign_key => 'authorization_id'
    end
  end

  include Behaviour
end