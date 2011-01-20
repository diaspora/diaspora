class DataPoint < ActiveRecord::Base
  attr_accessor :descriptor
  attr_accessor :value

  belongs_to :statistic
end
