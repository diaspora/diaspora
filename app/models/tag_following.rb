class TagFollowing < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag, :class_name => "ActsAsTaggableOn::Tag"

  validates_uniqueness_of :tag_id, :scope => :user_id
end
