# frozen_string_literal: true

class RemoveAuthenticationTokenFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_index :users, column: :authentication_token, name: :index_users_on_authentication_token, unique: true
    remove_column :users, :authentication_token, :string, limit: 30
  end
end
