class CreateUserPreferences < ActiveRecord::Migration
  def self.up
    create_table :user_preferences do |t|
      t.string :email_type
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_preferences
  end
end
