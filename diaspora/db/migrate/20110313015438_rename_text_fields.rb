class RenameTextFields < ActiveRecord::Migration
  def self.up
    rename_column :posts, :message, :text
    execute("UPDATE posts
            SET text = posts.caption
            WHERE posts.caption IS NOT NULL;")
    remove_column :posts, :caption
  end

  def self.down
  end
end
