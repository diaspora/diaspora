class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.belongs_to :user, index: true
      t.belongs_to :o_auth_application, index: true

      t.timestamps null: false
    end
  end
end
