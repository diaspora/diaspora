class PmForeignKeys < ActiveRecord::Migration
  def self.delete_disconnected_cvs
    execute <<SQL
    DELETE conversation_visibilities FROM conversation_visibilities
      LEFT OUTER JOIN conversations ON conversation_visibilities.conversation_id = conversations.id
      LEFT OUTER JOIN people ON conversation_visibilities.person_id = people.id
    WHERE people.id IS NULL OR conversations.id IS NULL
SQL
  end
  def self.delete_disconnected_messages
    execute <<SQL
    DELETE messages FROM messages
      LEFT OUTER JOIN conversations ON messages.conversation_id = conversations.id
      LEFT OUTER JOIN people ON messages.author_id = people.id
    WHERE people.id IS NULL OR conversations.id IS NULL
SQL
  end
  def self.delete_disconnected_conversations
    execute <<SQL
    DELETE conversations FROM conversations
      LEFT OUTER JOIN people ON conversations.author_id = people.id
    WHERE people.id IS NULL
SQL
  end
  def self.up
    delete_disconnected_conversations
    delete_disconnected_messages
    delete_disconnected_cvs

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
