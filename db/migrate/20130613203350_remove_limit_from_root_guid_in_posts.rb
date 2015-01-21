class RemoveLimitFromRootGuidInPosts < ActiveRecord::Migration
  def up
    remove_index 'posts', :name => 'index_posts_on_root_guid'
    remove_index 'posts', :name => 'index_posts_on_author_id_and_root_guid'
    change_column :posts, :root_guid, :string
    add_index 'posts', ["root_guid"], :name => 'index_posts_on_root_guid', length: {"root_guid"=>191}
    add_index 'posts', ["author_id", "root_guid"], :name => 'index_posts_on_author_id_and_root_guid', length: {"root_guid"=>190}, :using => :btree, :unique => true
  end

  def down
    change_column :posts, :root_guid, :string, limit: 30
  end
end
