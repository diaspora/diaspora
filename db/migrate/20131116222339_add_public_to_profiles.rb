class AddPublicToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :is_public, :boolean, :default => false
  end
end
