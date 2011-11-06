class Location < ActiveRecord::Base
  has_many :check_ins

  reverse_geocoded_by :longitude, :latitude
  geocoded_by :address

  after_validation :geocode, :reverse_geocode
end
