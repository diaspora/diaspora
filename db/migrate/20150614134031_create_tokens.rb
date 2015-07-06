class CreateTokens < ActiveRecord::Migration
  def self.up
    create_table :tokens do |t|
      t.belongs_to :o_auth_application, index: true
      t.string :token
      t.datetime :expires_at
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :tokens
  end
end
