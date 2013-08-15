class AddTumblrPostIdsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :tumblr_ids, :text
  end
end
