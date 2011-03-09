class AddSignaturesToMessage < ActiveRecord::Migration
  def self.up
    add_column(:messages, :author_signature, :text)
    add_column(:messages, :parent_author_signature, :text)
  end

  def self.down
    remove_column(:messages, :author_signature)
    remove_column(:messages, :parent_author_signature)
  end
end
