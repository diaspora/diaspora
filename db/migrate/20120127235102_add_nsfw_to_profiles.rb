class AddNsfwToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :nsfw, :boolean, :default => false
  end

  def self.down
    remove_column :profiles, :nsfw
  end
end
