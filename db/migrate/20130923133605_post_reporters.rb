class PostReporters < ActiveRecord::Migration
  def up
    add_index :post_reporters, :post_id
  end

  def down
    remove_index :post_reporters, column => :post_id
  end
end
