# frozen_string_literal: true

class AddSignatureToAccountMigration < ActiveRecord::Migration[5.2]
  def change
    add_column :account_migrations, :signature, :text
  end
end
