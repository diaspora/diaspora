# frozen_string_literal: true

class AddMissingIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :photos, :author_id
    add_index :user_preferences, %i[user_id email_type], length: {email_type: 190}
    add_index :locations, :status_message_id
  end
end
