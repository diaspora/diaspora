class RemoveDeletedAspectsFromAutoFollowBack < ActiveRecord::Migration
  def up
    User.where.not(auto_follow_back_aspect_id: Aspect.select(:id))
      .where(auto_follow_back: true)
      .update_all(auto_follow_back: false, auto_follow_back_aspect_id: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
