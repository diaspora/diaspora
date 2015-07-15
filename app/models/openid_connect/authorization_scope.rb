class OpenidConnect::AuthorizationScope < ActiveRecord::Base
  belongs_to :authorization
  belongs_to :scope

  validates :authorization, presence: true
  validates :scope, presence: true
end
