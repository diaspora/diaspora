class GroupPost < ActiveRecord::Base
  belongs_to :group
  belongs_to :post

  validates :group_id, :presence => true
  validates :post_id, :presence => true
end
