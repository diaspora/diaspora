class CreateServiceUsers < ActiveRecord::Migration
  def self.up
    create_table :service_users do |t|
      t.string :uid, :null => false
      t.string :name, :null => false
      t.string :picture_url, :null => false
      t.integer :service_id, :null => false
      t.integer :person_id
      t.integer :contact_id
      t.integer :request_id
      t.timestamps
    end

    add_index :service_users, :service_id
  end

  def self.down
    drop_table :service_users
  end
end
