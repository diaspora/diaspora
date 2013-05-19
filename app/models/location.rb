class Location < ActiveRecord::Base

  before_validation :split_coords, :on => :create

  attr_accessor :coordinates

  belongs_to :status_message

  def split_coords
    coordinates.present? ? (self.lat, self.lng = coordinates.split(',')) : false
  end
end
