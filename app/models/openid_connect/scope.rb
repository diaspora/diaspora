class OpenidConnect::Scope < ActiveRecord::Base
  has_many :o_auth_access_token, through: :scope_tokens
  has_many :authorizations, through: :authorization_scopes

  validates :name, presence: true, uniqueness: true

  # TODO: Incomplete class
end
