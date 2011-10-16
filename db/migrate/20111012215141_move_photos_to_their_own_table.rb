class MovePhotosToTheirOwnTable < ActiveRecord::Migration
  def self.up
    create_table "photos", :force => true do |t|
      t.integer  "author_id", :null => false
      t.boolean  "public", :default => false, :null => false
      t.string   "diaspora_handle"
      t.string   "guid", :null => false
      t.boolean  "pending", :default => false, :null => false
      t.text     "text"
      t.text     "remote_photo_path"
      t.string   "remote_photo_name"
      t.string   "random_string"
      t.string   "processed_image"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "unprocessed_image"
      t.string   "status_message_guid"
      t.integer  "comments_count"
    end

    execute <<SQL
INSERT INTO photos
SELECT id, author_id, public, diaspora_handle, guid, pending, text, remote_photo_path, remote_photo_name, random_string, processed_image,
created_at, updated_at, unprocessed_image, status_message_guid, comments_count
FROM posts
WHERE type = 'Photo'
SQL

    execute "UPDATE aspect_visibilities AS av, photos SET av.shareable_type='Photo' WHERE av.shareable_id=photos.id"
    execute "UPDATE share_visibilities AS sv, photos SET sv.shareable_type='Photo' WHERE sv.shareable_id=photos.id"

    # all your base are belong to us!
    execute "DELETE FROM posts WHERE type='Photo'"
  end


  def self.down
    execute <<SQL
INSERT INTO posts
  SELECT NULL AS id, author_id, public, diaspora_handle, guid, pending, 'Photo' AS type, text, remote_photo_path, remote_photo_name, random_string,
    processed_image, NULL AS youtube_titles, created_at, updated_at, unprocessed_image, NULL AS object_url, NULL AS image_url, NULL AS image_height, NULL AS image_width, NULL AS provider_display_name,
    NULL AS actor_url, NULL AS objectId, NULL AS root_guid, status_message_guid, 0 AS likes_count, comments_count, NULL AS o_embed_cache_id
  FROM photos
SQL

    execute <<SQL
UPDATE aspect_visibilities, posts, photos
SET
aspect_visibilities.shareable_id=posts.id,
aspect_visibilities.shareable_type='Post'
WHERE
posts.guid=photos.guid AND
photos.id=aspect_visibilities.shareable_id
SQL

    execute <<SQL
UPDATE share_visibilities, posts, photos
SET
share_visibilities.shareable_id=posts.id,
share_visibilities.shareable_type='Post'
WHERE
posts.guid=photos.guid AND
photos.id=share_visibilities.shareable_id
SQL

    execute "DROP TABLE photos"
  end
end
