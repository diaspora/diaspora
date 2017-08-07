class AddPublicToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :public_details, :boolean, default: false
  end
end
