class FixPhotoPublicFlag < ActiveRecord::Migration
  def up
    Photo.joins(:status_message).where(posts: {public: true}).update_all(public: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
