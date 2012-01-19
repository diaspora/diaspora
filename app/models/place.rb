class Place < ActiveRecord::Base
  has_one :description, :dependent => :destroy
  delegate :title, :image_url, :to => :description
  accepts_nested_attributes_for :description

end


