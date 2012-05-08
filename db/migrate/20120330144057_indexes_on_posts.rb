class IndexesOnPosts < ActiveRecord::Migration
  def change
    add_index(:posts, [:id, :type, :created_at])
  end
end
