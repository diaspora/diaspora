class CommentAnything < ActiveRecord::Migration
  def self.up
    remove_foreign_key :comments, :posts
    remove_index :comments, :post_id
    change_table :comments do |t|
      t.rename :post_id, :commentable_id
      t.string :commentable_type, :default => 'Post', :null => false, :limit => 60
    end
  end

  def self.down
    rename_column :comments, :commentable_id, :post_id
    add_foreign_key :comments, :posts, :dependent => :delete
    add_index :comments, :post_id

    remove_column :comments, :commentable_type
  end
end
