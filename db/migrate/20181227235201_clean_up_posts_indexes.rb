# frozen_string_literal: true

class CleanUpPostsIndexes < ActiveRecord::Migration[5.1]
  def change
    remove_index :posts, %i[id type created_at]
    remove_index :posts, :tweet_id
    add_index :posts, %i[created_at id]
  end
end
