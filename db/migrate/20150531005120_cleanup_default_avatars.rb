class CleanupDefaultAvatars < ActiveRecord::Migration
  def up
    Profile.where("image_url LIKE ?", "%user/default%")
      .update_all(image_url: nil, image_url_small: nil, image_url_medium: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
