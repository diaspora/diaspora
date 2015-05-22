class CreateEventTables < ActiveRecord::Migration
  def up
    create_table :events do |t|
      t.string :name, :null => false
      t.belongs_to :status_message, :null => false
      t.string :location
      t.datetime :date
      t.string :guid
      t.timestamps
    end
    add_index :events, :status_message_id

    create_table :event_participations do |t|
      t.belongs_to :event, :null => false
      t.belongs_to :author, :null => false
      t.integer :intention, :null => false
      t.string :guid
      t.text :author_signature
      t.text :parent_author_signature
      t.timestamps
    end
    add_index :event_participations, :event_id
  end

  def down
    drop_table :event_participations
    drop_table :events
  end
end
