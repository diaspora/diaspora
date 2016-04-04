class AddAuthorIdIndexToParticipations < ActiveRecord::Migration
  def change
    add_index :participations, :author_id, :using => :btree
  end
end
