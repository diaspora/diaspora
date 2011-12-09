class AddBirthdayDisplayToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :birthday_display, :string, :default => 'full'
  end

  def self.down
    remove_column :profiles, :birthday_display
  end
end
