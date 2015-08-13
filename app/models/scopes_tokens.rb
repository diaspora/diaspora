class ScopeToken < ActiveRecord::Base
  belongs_to :scope
  belongs_to :token

  validates :scope, presence: true
  validates :token, presence: true
end
