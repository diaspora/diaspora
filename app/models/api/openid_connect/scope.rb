module Api
  module OpenidConnect
    class Scope < ActiveRecord::Base
      has_many :authorizations, through: :authorization_scopes

      validates :name, presence: true, uniqueness: true

      # TODO: Add constants so scopes can be referenced as OpenidConnect::Scope::Read
    end
  end
end
