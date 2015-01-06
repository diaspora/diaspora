class RemoveLimitFromRootGuidInPosts < ActiveRecord::Migration
  def up
    change_column :posts, :root_guid, :string, limit: 64
  end

  def down
    change_column :posts, :root_guid, :string, limit: 64
  end
end
