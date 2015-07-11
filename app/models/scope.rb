class Scope < ActiveRecord::Base
  has_many :tokens, through: :scope_tokens
  has_many :authorizations, through: :authorization_scopes

  validates :name, presence: true, uniqueness: true

  # TODO: Incomplete class
end
