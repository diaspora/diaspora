class AddInteractedAtToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :interacted_at, :datetime
  end

  def self.down
    remove_column :posts, :interacted_at
  end
end
