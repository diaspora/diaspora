# Place Mentions allows to create a relationship between places and post.
# Also allows to save review information related to that place.
#
class PlaceMention < ActiveRecord::Base
  belongs_to :post
  belongs_to :place
  validates :post, :presence => true
  validates :place, :presence => true


end
