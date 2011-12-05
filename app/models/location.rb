class Location < ActiveRecord::Base
  has_many :check_ins

  geocoded_by :address
  reverse_geocoded_by :latitude, :longitude

  after_validation :geocode

  after_validation :reverse_geocode, :if => lambda { |object| object.address.nil? }
end
