class AddTweetIdToPost < ActiveRecord::Migration
  def change
  	add_column :posts, :tweet_id, :string, limit: 64
  	add_index :posts, :tweet_id
  end
end
