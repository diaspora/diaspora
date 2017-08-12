class RemoveSignaturesFromRelayables < ActiveRecord::Migration[4.2]
  def change
    remove_column :comments, :parent_author_signature, :text
    remove_column :poll_participations, :parent_author_signature, :text
    remove_column :messages, :parent_author_signature, :text
    remove_column :participations, :parent_author_signature, :text
    remove_column :likes, :parent_author_signature, :text
  end
end
