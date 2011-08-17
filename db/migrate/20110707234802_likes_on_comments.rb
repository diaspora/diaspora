class LikesOnComments < ActiveRecord::Migration
  class Like < ActiveRecord::Base; end
  def self.up
    remove_foreign_key :likes, :posts

    add_column :likes, :target_type, :string, :limit => 60, :null => false
    rename_column :likes, :post_id, :target_id

    add_column :comments, :likes_count, :integer, :default => 0, :null => false

    execute <<SQL
      UPDATE likes
        SET target_type = 'Post'
SQL
    execute <<SQL
      UPDATE posts
        SET likes_count = (SELECT COUNT(*) FROM likes WHERE likes.target_id = posts.id AND likes.target_type = 'Post')
SQL

    #There are some duplicate likes.
    if Like.count > 0
      keeper_likes = Like.group(:target_id, :author_id, :target_type).having('COUNT(*) > 1')
      keeper_likes.each do |like|
        l = Like.arel_table
        Like.where(:target_id => like.target_id, :author_id => like.author_id, :target_type => like.target_type).where(l[:id].not_eq(like.id)).delete_all
      end
    end
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
