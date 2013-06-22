class RemoveLimitFromRootGuidInPosts < ActiveRecord::Migration
  def up
    change_column :posts, :root_guid, :string
  end

  def down
    change_column :posts, :root_guid, :string, limit: 30
  end
end
