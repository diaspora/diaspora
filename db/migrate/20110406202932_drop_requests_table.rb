class DropRequestsTable < ActiveRecord::Migration
  class Contact < ActiveRecord::Base; end

  def self.up
    remove_foreign_key :requests, :column => :recipient_id
    remove_foreign_key :requests, :column => :sender_id

    remove_index :requests, :mongo_id
    remove_index :requests, :recipient_id
    remove_index :requests, [:sender_id, :recipient_id]
    remove_index :requests, :sender_id

    execute 'DROP TABLE requests'

    execute( <<SQL
      DELETE contacts.* FROM contacts
        WHERE contacts.sharing = false
SQL
    ) if Contact.count > 0
  end

  def self.down
    create_table :requests, :force => true do |t|
      t.integer  :sender_id,    :null => false
      t.integer  :recipient_id, :null => false
      t.integer  :aspect_id
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :mongo_id
    end

    add_index :requests, ["mongo_id"], :name => "index_requests_on_mongo_id"
    add_index :requests, ["recipient_id"], :name => "index_requests_on_recipient_id"
    add_index :requests, ["sender_id", "recipient_id"], :name => "index_requests_on_sender_id_and_recipient_id", :unique => true
    add_index :requests, ["sender_id"], :name => "index_requests_on_sender_id"

    add_foreign_key :requests, :people, :column => "recipient_id", :dependent => :delete
    add_foreign_key :requests, :people, :column => "sender_id", :dependent => :delete
  end
end
