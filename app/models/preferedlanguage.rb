class Preferedlanguage < ActiveRecord::Base
  attr_accessible :iso_code, :name
  has_and_belongs_to_many :users
end
