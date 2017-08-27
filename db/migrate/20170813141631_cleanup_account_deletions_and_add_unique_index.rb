# frozen_string_literal: true

class CleanupAccountDeletionsAndAddUniqueIndex < ActiveRecord::Migration[5.1]
  def up
    remove_column :account_deletions, :diaspora_handle

    duplicate_query = "WHERE a1.person_id = a2.person_id AND a1.id > a2.id"
    if AppConfig.postgres?
      execute("DELETE FROM account_deletions AS a1 USING account_deletions AS a2 #{duplicate_query}")
    else
      execute("DELETE a1 FROM account_deletions a1, account_deletions a2 #{duplicate_query}")
    end

    add_index :account_deletions, :person_id, name: :index_account_deletions_on_person_id, unique: true
  end

  def down
    remove_index :account_deletions, name: :index_account_deletions_on_person_id
    add_column :account_deletions, :diaspora_handle, :string
  end
end
