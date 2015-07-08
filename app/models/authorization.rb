class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :o_auth_application
  has_and_belongs_to_many :scopes

  # TODO: Incomplete class
end
