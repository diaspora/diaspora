# frozen_string_literal: true

class RemoveChat < ActiveRecord::Migration[5.1]
  def up
    remove_column :aspects, :chat_enabled
    drop_table :chat_contacts
    drop_table :chat_fragments
    drop_table :chat_offline_messages
  end
end
