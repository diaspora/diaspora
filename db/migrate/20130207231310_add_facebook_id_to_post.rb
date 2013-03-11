class AddFacebookIdToPost < ActiveRecord::Migration
  def change
    add_column :posts, :facebook_id, :string
  end
end
