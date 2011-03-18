class CreateServiceUsers < ActiveRecord::Migration
  def self.up
    create_table :service_users do |t|
      t.string :uid
      t.string :name
      t.integer :service_id
      t.integer :person_id
      t.integer :contact_id
      t.integer :request_id
      t.timestamps
    end
  end

  def self.down
    drop_table :service_users
  end
end
