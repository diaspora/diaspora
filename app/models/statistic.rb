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

  def distribution_as_array
    dist = distribution
    arr = []
    (0..dist.size-1).each do |key|
      arr << dist[key.to_s]
    end
    arr
  end

  def users_in_sample 
    @users ||= lambda {
      users = self.data_points.map{|d| d.value}
      users.inject do |total,curr|
        total += curr
      end
    }.call
  end

  def generate_graph
    g = Gruff::Bar.new
    g.title = "Posts per user today"
    g.data("Users", self.distribution_as_array)

    h = {}
    distribution.keys.each{|k| h[k.to_i] = k.to_s }

    g.labels = h
    g.to_blob
  end
end
