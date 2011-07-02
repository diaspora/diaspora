class CreateTagFollowings < ActiveRecord::Migration
  def self.up
    create_table :tag_followings do |t|
      t.integer :tag_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_followings
  end
end
