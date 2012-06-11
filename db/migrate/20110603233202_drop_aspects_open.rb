class DropAspectsOpen < ActiveRecord::Migration
  require Rails.root.join("db", "migrate", "20110202015222_add_open_to_aspects")
  def self.up
    AddOpenToAspects.down
  end

  def self.down
    AddOpenToAspects.up
  end
end
