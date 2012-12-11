class Location < ActiveRecord::Base

  before_validation :split_coords, :on => :create

  attr_accessor :coordinates

  belongs_to :status_message

  def split_coords
    begin
      self.lat, self.lng = coordinates.split(',')
    rescue Exception => e
      puts e.message
      false
    end
  end
end
