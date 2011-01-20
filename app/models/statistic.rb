class Statistic < ActiveRecord::Base
  has_many :data_points, :class_name => 'DataPoint'

  def compute_average
    users = 0
    sum = 0
    self.data_points.each do |d|
      sum += d.key*d.value
      users += d.value
    end
    self.average = sum.to_f/users
  end

  def distribution
    @dist ||= lambda {
      dist = {}
      self.data_points.each do |d|
        dist[d.key] = d.value.to_f/users_in_sample
      end
      dist
    }.call
  end

  def users_in_sample 
    @users ||= lambda {
      users = self.data_points.map{|d| d.value}
      users.inject do |total,curr|
        total += curr
      end
    }.call
  end
end
