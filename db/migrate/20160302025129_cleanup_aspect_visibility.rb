class CleanupAspectVisibility < ActiveRecord::Migration[4.2]
  class AspectVisibility < ApplicationRecord
  end

  def up
    AspectVisibility.joins("LEFT OUTER JOIN posts ON posts.id = aspect_visibilities.shareable_id")
                    .where(shareable_type: "Post").where("posts.id is NULL").delete_all
    AspectVisibility.joins("LEFT OUTER JOIN photos ON photos.id = aspect_visibilities.shareable_id")
                    .where(shareable_type: "Photo").where("photos.id is NULL").delete_all
    AspectVisibility.joins("INNER JOIN posts ON posts.id = aspect_visibilities.shareable_id")
                    .where(shareable_type: "Post").where(posts: {public: true}).delete_all
    AspectVisibility.joins("INNER JOIN photos ON photos.id = aspect_visibilities.shareable_id")
                    .where(shareable_type: "Photo").where(photos: {public: true}).delete_all

    remove_columns :aspect_visibilities, :created_at, :updated_at
  end

  def down
    add_column :aspect_visibilities, :created_at, :datetime
    add_column :aspect_visibilities, :updated_at, :datetime

    User.all.each do |user|
      user.posts.where(public: true).each {|post| user.add_to_streams(post, user.aspects) }
      user.photos.where(public: true).each {|photo| user.add_to_streams(photo, user.aspects) }
    end
  end
end
