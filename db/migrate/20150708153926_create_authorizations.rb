class CreateAuthorizations < ActiveRecord::Migration[4.2]
  def change
    create_table :authorizations do |t|
      t.belongs_to :user, index: true
      t.belongs_to :o_auth_application, index: true
      t.string :refresh_token
      t.string :code
      t.string :redirect_uri
      t.string :nonce
      t.string :scopes
      t.boolean :code_used, default: false

      t.timestamps null: false
    end
    add_foreign_key :authorizations, :users
    add_foreign_key :authorizations, :o_auth_applications
  end
end
