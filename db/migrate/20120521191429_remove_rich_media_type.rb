class RemoveRichMediaType < ActiveRecord::Migration
  def up
    execute("UPDATE posts SET frame_name='Night' WHERE frame_name='rich-media'")
  end

  def down
  end
end
