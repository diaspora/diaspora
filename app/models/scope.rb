class Scope < ActiveRecord::Base
  has_and_belongs_to_many :tokens
  has_and_belongs_to_many :authorizations

  validates :name, presence: true, uniqueness: true

  # TODO: Incomplete class
end
