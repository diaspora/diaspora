require File.join(Rails.root, 'db/migrate/20110319005509_add_processed_to_post')
class UnprocessedImageUploader < ActiveRecord::Migration
  def self.up
    AddProcessedToPost.down
    rename_column :posts, :image, :processed_image
    add_column :posts, :unprocessed_image, :string
  end

  def self.down
    remove_column :posts, :unprocessed_image
    rename_column :posts, :processed_image, :image
    AddProcessedToPost.up
  end
end
