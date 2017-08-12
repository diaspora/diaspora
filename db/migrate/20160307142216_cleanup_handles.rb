class CleanupHandles < ActiveRecord::Migration[4.2]
  def change
    remove_column :photos, :tmp_old_id, :integer
    remove_column :photos, :diaspora_handle, :string
    remove_column :posts, :diaspora_handle, :string
  end
end
