# frozen_string_literal: true

class CleanupInvalidLikes < ActiveRecord::Migration[5.1]
  class Like < ApplicationRecord
  end

  def up
    Like.where(target_type: "Post").joins("LEFT OUTER JOIN posts ON posts.id = likes.target_id")
        .where("posts.id IS NULL").delete_all
    Like.where(target_type: "Comment").joins("LEFT OUTER JOIN comments ON comments.id = likes.target_id")
        .where("comments.id IS NULL").delete_all
  end
end
