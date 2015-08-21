module Api
  module OpenidConnect
    class Scope < ActiveRecord::Base
      has_many :authorizations, through: :authorization_scopes

      validates :name, presence: true, uniqueness: true
    end
  end
end
