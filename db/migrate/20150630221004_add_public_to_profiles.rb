class AddPublicToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :public_details, :boolean, default: false
  end
end
