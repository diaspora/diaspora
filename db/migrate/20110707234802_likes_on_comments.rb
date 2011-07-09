class LikesOnComments < ActiveRecord::Migration
  def self.up
    remove_foreign_key :likes, :posts

    add_column :likes, :target_type, :string, :null => false
    rename_column :likes, :post_id, :target_id

    add_column :comments, :likes_count, :integer, :default => 0, :null => false

    execute <<SQL
      UPDATE likes
        SET target_type = 'Post'
SQL

    add_index :likes, [:target_id, :author_id, :target_type], :unique => true
  end

  def self.down
    remove_column :comments, :likes_count

    remove_column :likes, :target_type
    rename_column :likes, :target_id, :post_id
    add_index :likes, :post_id
    remove_index :likes, :target_id
  end
end
