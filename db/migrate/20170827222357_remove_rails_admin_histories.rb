# frozen_string_literal: true

class RemoveRailsAdminHistories < ActiveRecord::Migration[5.1]
  def up
    drop_table :rails_admin_histories
  end

  def down
    create_table :rails_admin_histories do |t|
      t.text     :message
      t.string   :username
      t.integer  :item
      t.string   :table
      t.integer  :month,      limit: 2
      t.integer  :year,       limit: 8
      t.datetime :created_at,           null: false
      t.datetime :updated_at,           null: false
    end

    add_index :rails_admin_histories, %i[item table month year], name:   :index_rails_admin_histories,
                                                                 length: {table: 188}
  end
end
