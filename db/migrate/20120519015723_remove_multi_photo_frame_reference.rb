class RemoveMultiPhotoFrameReference < ActiveRecord::Migration
  def up
    execute("UPDATE posts SET frame_name='Day' WHERE frame_name='multi-photo'")
  end

  def down
  end
end
