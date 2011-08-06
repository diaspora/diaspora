class AddProcessedToPost < ActiveRecord::Migration
  def self.up
    add_column(:posts, :processed, :boolean, :default => true)
  end

  def self.down
    remove_column(:posts, :processed)
  end
end
