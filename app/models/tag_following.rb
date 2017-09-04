# frozen_string_literal: true

class TagFollowing < ApplicationRecord
  belongs_to :user
  belongs_to :tag, :class_name => "ActsAsTaggableOn::Tag"

  validates_uniqueness_of :tag_id, :scope => :user_id

  def self.user_is_following?(user, tagname)
    tagname.nil? ? false : joins(:tag).where(:tags => {:name => tagname.downcase}).where(:user_id => user.id).exists?
  end

end
