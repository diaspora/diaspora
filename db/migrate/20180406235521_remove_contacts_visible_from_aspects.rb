# frozen_string_literal: true

class RemoveContactsVisibleFromAspects < ActiveRecord::Migration[5.1]
  def change
    remove_index :aspects, column: %i[user_id contacts_visible], name: :index_aspects_on_user_id_and_contacts_visible
    remove_column :aspects, :contacts_visible, :boolean, default: true, null: false
  end
end
