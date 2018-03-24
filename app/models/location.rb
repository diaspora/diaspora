# frozen_string_literal: true

class Location < ApplicationRecord
  before_validation :split_coords, on: :create
  validates_presence_of :lat, :lng

  attr_accessor :coordinates

  include Diaspora::Federated::Base

  belongs_to :status_message

  def split_coords
    self.lat, self.lng = coordinates.split(',') if coordinates.present?
  end
end
