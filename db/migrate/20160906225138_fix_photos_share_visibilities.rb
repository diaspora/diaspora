# frozen_string_literal: true

class FixPhotosShareVisibilities < ActiveRecord::Migration[4.2]
  class Photo < ApplicationRecord
  end

  class ShareVisibility < ApplicationRecord
  end

  def up
    Photo.joins("INNER JOIN posts ON posts.guid = photos.status_message_guid")
         .where(posts: {type: "StatusMessage", public: true}).update_all(public: true)

    ShareVisibility.joins("INNER JOIN photos ON photos.id = share_visibilities.shareable_id")
                   .where(shareable_type: "Photo", photos: {public: true}).delete_all

    remove_duplicates
    remove_index :share_visibilities, name: :shareable_and_user_id
    add_index :share_visibilities, %i(shareable_id shareable_type user_id), name: :shareable_and_user_id, unique: true

    execute "INSERT INTO share_visibilities (user_id, shareable_id, shareable_type) " \
            "SELECT post_visibility.user_id, photos.id, 'Photo' FROM photos " \
            "INNER JOIN posts ON posts.guid = photos.status_message_guid AND posts.type = 'StatusMessage' " \
            "LEFT OUTER JOIN share_visibilities ON share_visibilities.shareable_id = photos.id " \
            "INNER JOIN share_visibilities AS post_visibility ON post_visibility.shareable_id = posts.id " \
            "WHERE photos.public = false AND share_visibilities.shareable_id IS NULL " \
            "AND post_visibility.shareable_type = 'Post'"
  end

  def down
    remove_index :share_visibilities, name: :shareable_and_user_id
    add_index :share_visibilities, %i(shareable_id shareable_type user_id), name: :shareable_and_user_id
  end

  def remove_duplicates
    where = "WHERE s1.user_id = s2.user_id AND s1.shareable_id = s2.shareable_id AND "\
      "s1.shareable_type = s2.shareable_type AND s1.id > s2.id"
    if AppConfig.postgres?
      execute("DELETE FROM share_visibilities AS s1 USING share_visibilities AS s2 #{where}")
    else
      execute("DELETE s1 FROM share_visibilities s1, share_visibilities s2 #{where}")
    end
  end
end
