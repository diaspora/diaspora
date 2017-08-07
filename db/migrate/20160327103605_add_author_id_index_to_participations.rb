class AddAuthorIdIndexToParticipations < ActiveRecord::Migration[4.2]
  def change
    add_index :participations, :author_id, :using => :btree
  end
end
