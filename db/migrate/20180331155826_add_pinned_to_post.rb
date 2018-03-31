class AddPinnedToPost < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :pinned, :boolean, default: false, index: true
  end
end
