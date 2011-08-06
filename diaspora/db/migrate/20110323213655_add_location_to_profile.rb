class AddLocationToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :location, :string
  end

  def self.down
    remove_column :profiles, :location
  end
end
