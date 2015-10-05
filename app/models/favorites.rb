class Favorites < ActiveRecord::Base
  validates :user_id, presence: true
  validates :post_id, presence: true

  validate :entry_does_not_exist, :on => :create

  belongs_to :user
  belongs_to :post

  def item
    Favorites.where(post_id: post_id, user_id: user_id)
  end

  def entry_does_not_exist
    if item.exists?
      errors[:base] << 'You cannot add the same post twice.'
    end
  end
end
