class Statistic < ActiveRecord::Base
  has_many :data_points, :class_name => 'DataPoint'

  def compute_average
    users = 0
    sum = 0
    self.data_points.each do |d|
      sum += d.key.to_i*d.value
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
    distribution.keys.each do |k|
      if k.to_i%10 ==0
        h[k.to_i] = k.to_s
      end
    end

    g.labels = h
    g.to_blob
  end
  
  def self.generate(time=Time.now, post_range=(0..50))
    stat = Statistic.new(:type => "posts_per_day", :time => time)
    post_range.each do |n|
      data_point = DataPoint.users_with_posts_on_day(time,n)
      data_point.save
      stat.data_points << data_point
    end
    stat.compute_average
    stat.save
    stat
  end
end
