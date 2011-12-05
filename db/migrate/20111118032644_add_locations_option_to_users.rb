class AddLocationsOptionToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :enable_location_services, :boolean
  end

  def self.down
    remove_column :users, :enable_location_services
  end
end
