class CreateOAuthApplications < ActiveRecord::Migration
  def self.up
    create_table :o_auth_applications do |t|
      t.belongs_to :user, index: true
      t.string :client_id
      t.string :client_secret

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :o_auth_applications
  end
end
