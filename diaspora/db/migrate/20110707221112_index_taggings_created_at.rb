class IndexTaggingsCreatedAt < ActiveRecord::Migration
  def self.up
    add_index :taggings, :created_at
  end

  def self.down
  end
end
