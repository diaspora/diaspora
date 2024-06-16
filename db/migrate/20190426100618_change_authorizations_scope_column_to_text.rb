# frozen_string_literal: true

class ChangeAuthorizationsScopeColumnToText < ActiveRecord::Migration[5.1]
  def change
    change_column :authorizations, :scopes, :text
  end
end
