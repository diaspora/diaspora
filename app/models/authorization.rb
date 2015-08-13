class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :o_auth_application
  has_many :scopes, through: :authorization_scopes

  # TODO: Incomplete class
end
