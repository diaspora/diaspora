class Statistc < ActiveRecord::Base
  attr_accessor :average

  has_many :data_points, :class_name => 'DataPoint'
end
