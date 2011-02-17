class UndoAddingIndicies < ActiveRecord::Migration
  require File.join(Rails.root, 'db/migrate/20110213052742_add_more_indicies')
  def self.up
    AddMoreIndicies.down
  end

  def self.down
    AddMoreIndicies.up
  end
end
