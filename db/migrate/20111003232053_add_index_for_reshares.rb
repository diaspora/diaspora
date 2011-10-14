class AddIndexForReshares < ActiveRecord::Migration
  def self.up
    add_index :posts, [:author_id, :root_guid], :unique => true
  end

  def self.down
    remove_index :posts, :column => [:author_id, :root_guid]
  end
end
