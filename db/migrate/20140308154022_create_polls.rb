class CreatePolls < ActiveRecord::Migration
  def up
    create_table :polls do |t|
      t.string :question, :null => false
      t.belongs_to :status_message, :null => false
      t.boolean :status
      t.string :guid
      t.timestamps
    end
    add_index :polls, :status_message_id

    create_table :poll_answers do |t|
      t.string :answer, :null => false
      t.belongs_to :poll, :null => false
      t.string :guid
      t.integer :vote_count, :default => 0
    end
    add_index :poll_answers, :poll_id

    create_table :poll_participations do |t|
      t.belongs_to :poll_answer, :null => false
      t.belongs_to :author, :null => false
      t.belongs_to :poll, :null => false
      t.string :guid
      t.text :author_signature
      t.text :parent_author_signature

      t.timestamps
    end
    add_index :poll_participations, :poll_id
  end

  def down
    drop_table :polls
    drop_table :poll_answers
    drop_table :poll_participations
  end
end
