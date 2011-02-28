class RenamePostToParentAndCreatorToAuthor < ActiveRecord::Migration
  def self.up
    rename_column :comments, :creator_signature, :author_signature
    rename_column :comments, :post_creator_signature, :parent_author_signature
  end

  def self.down
    rename_column :comments, :author_signature, :creator_signature
    rename_column :comments, :parent_author_signature, :post_creator_signature
  end
end
