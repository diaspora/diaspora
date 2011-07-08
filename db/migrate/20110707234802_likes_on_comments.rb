class LikesOnComments < ActiveRecord::Migration
  def self.up
    add_column :likes, :target_type, :string, :null => false
    add_column :likes, :target_id, :integer, :null => false
    remove_column :posts, :likes_count

    execute <<SQL
      UPDATE likes
        SET target_type = 'Post'
SQL
  end

  def self.down
    add_column :posts, :likes_count, :integer
    remove_column :likes, :target_type
    rename_column :likes, :target_id, :post_id
    add_index :likes, :post_id
  end
end
