class AddOpenAspectsToUser < ActiveRecord::Migration
  def self.up
    add_column(:users, :open_aspects, :text)
  end

  def self.down
    remove_column(:users, :open_aspects)
  end
end
