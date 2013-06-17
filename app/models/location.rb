class Location < ActiveRecord::Base
  before_validation :split_coords, on: :create
  validates_presence_of :lat, :lng

  attr_accessor :coordinates

  include Diaspora::Federated::Base
  xml_attr :address
  xml_attr :lat
  xml_attr :lng

  belongs_to :status_message

  def split_coords
    self.lat, self.lng = coordinates.split(',') if coordinates.present?
  end
end
