class AddFacebookIdToPost < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :facebook_id, :string
  end
end
