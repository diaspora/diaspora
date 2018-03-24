# frozen_string_literal: true

class PolymorphicMentions < ActiveRecord::Migration[4.2]
  def change
    remove_index :mentions, column: %i(post_id)
    remove_index :mentions, column: %i(person_id post_id), unique: true
    rename_column :mentions, :post_id, :mentions_container_id
    add_column :mentions, :mentions_container_type, :string
    add_index :mentions,
              %i(mentions_container_id mentions_container_type),
              name:   "index_mentions_on_mc_id_and_mc_type",
              length: {mentions_container_type: 191}
    add_index :mentions,
              %i(person_id mentions_container_id mentions_container_type),
              name:   "index_mentions_on_person_and_mc_id_and_mc_type",
              length: {mentions_container_type: 191},
              unique: true

    reversible(&method(:up_down))
  end

  class Mention < ApplicationRecord
  end

  class Notification < ApplicationRecord
  end

  def up_down(change)
    change.up do
      Mention.update_all(mentions_container_type: "Post")
      change_column :mentions, :mentions_container_type, :string, null: false
      Notification.where(type: "Notifications::Mentioned").update_all(type: "Notifications::MentionedInPost")
    end

    change.down do
      Notification.where(type: "Notifications::MentionedInPost").update_all(type: "Notifications::Mentioned")
      Mention.where(mentions_container_type: "Comment").destroy_all
      Notification.where(type: "Notifications::MentionedInComment").destroy_all
    end
  end
end
