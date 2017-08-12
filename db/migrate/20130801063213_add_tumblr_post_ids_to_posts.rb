class AddTumblrPostIdsToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :tumblr_ids, :text
  end
end
