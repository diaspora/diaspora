class MovePhotosToTheirOwnTable < ActiveRecord::Migration
  def self.up
    create_table "photos", :force => true do |t|
      t.integer  "tmp_old_id", :null => true
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

    if AppConfig.postgres?
      execute %{
        INSERT INTO photos (
            tmp_old_id
          , author_id
          , public
          , diaspora_handle
          , guid
          , pending
          , text
          , remote_photo_path
          , remote_photo_name
          , random_string
          , processed_image
          , created_at
          , updated_at
          , unprocessed_image
          , status_message_guid
          , comments_count
        ) SELECT
            id
          , author_id
          , public
          , diaspora_handle
          , guid
          , pending
          , text
          , remote_photo_path
          , remote_photo_name
          , random_string
          , processed_image
          , created_at
          , updated_at
          , unprocessed_image
          , status_message_guid
          , comments_count
        FROM
          posts
        WHERE
          type = 'Photo'
      }

      execute "UPDATE aspect_visibilities SET shareable_type='Photo' FROM photos WHERE shareable_id=photos.id"
      execute "UPDATE share_visibilities SET shareable_type='Photo' FROM photos WHERE shareable_id=photos.id"
    else
      execute <<SQL
INSERT INTO photos
SELECT NULL as id, id AS tmp_old_id, author_id, public, diaspora_handle, guid, pending, text, remote_photo_path, remote_photo_name, random_string, processed_image,
created_at, updated_at, unprocessed_image, status_message_guid, comments_count
FROM posts
WHERE type = 'Photo'
SQL

      execute "UPDATE aspect_visibilities AS av, photos SET av.shareable_type='Photo' WHERE av.shareable_id=photos.id"
      execute "UPDATE share_visibilities AS sv, photos SET sv.shareable_type='Photo' WHERE sv.shareable_id=photos.id"
    end

    # all your base are belong to us!
    execute "DELETE FROM posts WHERE type='Photo'"
  end


  def self.down
    if AppConfig.postgres?
      execute %{
        INSERT INTO posts (
          id, author_id, public, diaspora_handle, guid, pending, type, text,
          remote_photo_path, remote_photo_name, random_string, processed_image,
          youtube_titles, created_at, updated_at, unprocessed_image,
          object_url, image_url, image_height, image_width,
          provider_display_name, actor_url, "objectId", root_guid,
          status_message_guid, likes_count, comments_count, o_embed_cache_id
        ) SELECT
          tmp_old_id, author_id, public, diaspora_handle, guid, pending, 'Photo', text,
          remote_photo_path, remote_photo_name, random_string, processed_image,
          NULL, created_at, updated_at, unprocessed_image, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, status_message_guid, 0, comments_count, NULL
        FROM photos
      }

      execute %{
        UPDATE
          aspect_visibilities
        SET
            shareable_id=posts.id
          , shareable_type='Post'
        FROM
            posts
          , photos
        WHERE
          posts.id=photos.tmp_old_id
          AND photos.id=aspect_visibilities.shareable_id
        }

      execute %{
        UPDATE
          share_visibilities
        SET
            shareable_id=posts.id
          , shareable_type='Post'
        FROM
            posts
          , photos
        WHERE
          posts.id=photos.tmp_old_id
          AND photos.id=share_visibilities.shareable_id
        }
    else
      execute <<SQL
INSERT INTO posts
  SELECT tmp_old_id AS id, author_id, public, diaspora_handle, guid, pending, 'Photo' AS type, text, remote_photo_path, remote_photo_name, random_string,
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
posts.id=photos.tmp_old_id AND
photos.id=aspect_visibilities.shareable_id
SQL

      execute <<SQL
UPDATE share_visibilities, posts, photos
SET
share_visibilities.shareable_id=posts.id,
share_visibilities.shareable_type='Post'
WHERE
posts.id=photos.tmp_old_id AND
photos.id=share_visibilities.shareable_id
SQL
      end

    execute "DROP TABLE photos"
  end
end
