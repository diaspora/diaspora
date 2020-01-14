# frozen_string_literal: true

class PhotosRemoveCommentCount < ActiveRecord::Migration[5.1]
  class Comment < ApplicationRecord
  end

  def change
    remove_column :photos, :comments_count, :integer

    reversible do |change|
      change.up { Comment.where(commentable_type: "Photo").delete_all }
    end
  end
end
