class UndoAddingIndicies < ActiveRecord::Migration
  def self.up
    AddMoreIndicies.down
  end

  def self.down
    AddMoreIndicies.up
  end
end
