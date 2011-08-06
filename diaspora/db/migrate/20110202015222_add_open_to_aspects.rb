class AddOpenToAspects < ActiveRecord::Migration
  def self.up
    add_column(:aspects, :open, :boolean, :default => false)
  end

  def self.down
    remove_column(:aspects, :open)
  end
end
