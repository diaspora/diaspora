class CleanupAspectVisibility < ActiveRecord::Migration
  class AspectVisibility < ActiveRecord::Base
  end

  def up
    AspectVisibility.joins("LEFT OUTER JOIN posts ON posts.id = aspect_visibilities.shareable_id")
      .where(shareable_type: "Post").delete_all("posts.id is NULL")
    AspectVisibility.joins("LEFT OUTER JOIN photos ON photos.id = aspect_visibilities.shareable_id")
      .where(shareable_type: "Photo").delete_all("photos.id is NULL")
    AspectVisibility.joins("INNER JOIN posts ON posts.id = aspect_visibilities.shareable_id")
      .where(shareable_type: "Post").delete_all(posts: {public: true})
    AspectVisibility.joins("INNER JOIN photos ON photos.id = aspect_visibilities.shareable_id")
      .where(shareable_type: "Photo").delete_all(photos: {public: true})

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
