class CleanupPostsTable < ActiveRecord::Migration[4.2]
  def change
    remove_index :posts, column: %i(status_message_guid pending),
                 name: :index_posts_on_status_message_guid_and_pending, length: {status_message_guid: 190}
    remove_index :posts, column: :status_message_guid, name: :index_posts_on_status_message_guid, length: 191
    remove_index :posts, column: %i(type pending id), name: :index_posts_on_type_and_pending_and_id

    # from photos?
    remove_column :posts, :pending, :boolean, default: false, null: false
    remove_column :posts, :remote_photo_path, :text
    remove_column :posts, :remote_photo_name, :string
    remove_column :posts, :random_string, :string
    remove_column :posts, :processed_image, :string
    remove_column :posts, :unprocessed_image, :string
    remove_column :posts, :status_message_guid, :string

    # old cubbi.es stuff
    remove_column :posts, :object_url, :string
    remove_column :posts, :image_url, :string
    remove_column :posts, :image_height, :integer
    remove_column :posts, :image_width, :integer
    remove_column :posts, :actor_url, :string
    remove_column :posts, :objectId, :string

    # old single post view templates
    remove_column :posts, :frame_name, :string

    add_index :posts, %i(id type), name: :index_posts_on_id_and_type
  end
end
