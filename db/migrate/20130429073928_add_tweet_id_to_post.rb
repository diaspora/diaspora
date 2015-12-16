class AddTweetIdToPost < ActiveRecord::Migration
  def change
  	add_column :posts, :tweet_id, :string
  	add_index :posts, ['tweet_id'], :length => { "tweet_id" => 191 }
  end
end
