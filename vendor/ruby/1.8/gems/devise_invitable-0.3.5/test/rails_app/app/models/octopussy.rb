# This model is here for the generators' specs
if DEVISE_ORM == :active_record
  class Octopussy < ActiveRecord::Base
    devise :database_authenticatable, :validatable, :confirmable
  end
elsif DEVISE_ORM == :mongoid
  class Octopussy
    include Mongoid::Document
    devise :database_authenticatable, :validatable, :confirmable
  end
end