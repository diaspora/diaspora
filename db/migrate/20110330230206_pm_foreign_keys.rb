class PmForeignKeys < ActiveRecord::Migration
  def self.up
    add_foreign_key :conversation_visibilities, :conversations, :dependent => :delete
    add_foreign_key :conversation_visibilities, :people, :dependent => :delete

    add_foreign_key :messages, :conversations, :dependent => :delete
    add_foreign_key :messages, :people, :column => :author_id, :dependent => :delete

    add_foreign_key :conversations, :people, :column => :author_id, :dependent => :delete
  end

  def self.down
    remove_foreign_key :conversation_visibilities, :conversations
    remove_foreign_key :conversation_visibilities, :people

    remove_foreign_key :messages, :conversations
    remove_foreign_key :messages, :people, :column => :author_id

    remove_foreign_key :conversations, :people, :column => :author_id
  end
end
