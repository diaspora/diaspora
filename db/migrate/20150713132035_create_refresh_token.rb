class RefreshToken < ActiveRecord::Migration
  def change
    create_table :refresh_token do
      t.belongs_to :token
      t.string :refresh_token

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :refresh_token
  end
end
