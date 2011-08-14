class LinkCommentsToPostByGuid < ActiveRecord::Migration
  def self.up
    add_column :comments, :post_guid, :string, :null => false
    add_index "comments", ["post_guid"], :name => "index_comments_on_post_guid"
 
    execute <<-SQL
      UPDATE comments SET comments.post_guid = 
        (SELECT posts.guid FROM posts WHERE posts.id = comments.post_id)
    SQL

    remove_foreign_key :comments, :post
    remove_column :comments, :post_id
  end

  def self.down
    add_column :comments, :post_id, :integer, :null => false
    add_foreign_key :comments, :posts
    add_index "comments", ["post_id"], :name => "index_comments_on_post_id"

    execute <<-SQL
      UPDATE comments SET comments.post_id = 
        (SELECT posts.id FROM posts WHERE posts.guid = comments.post_guid)
    SQL
    
    remove_column :comments, :post_guid
  end
end
