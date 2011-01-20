class Statistc < ActiveRecord::Base
  has_many :data_points, :class_name => 'DataPoint'
end
