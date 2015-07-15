class OpenidConnect::ScopeToken < ActiveRecord::Base
  belongs_to :scope
  belongs_to :o_auth_access_token

  validates :scope, presence: true
  validates :token, presence: true
end
