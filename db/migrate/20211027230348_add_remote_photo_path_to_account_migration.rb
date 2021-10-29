# frozen_string_literal: true

class AddRemotePhotoPathToAccountMigration < ActiveRecord::Migration[5.2]
  def change
    add_column :account_migrations, :remote_photo_path, :text
  end
end
