# frozen_string_literal: true

class CreateReferencesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :references do |t|
      t.integer  :source_id,              null: false
      t.string   :source_type, limit: 60, null: false
      t.integer  :target_id,              null: false
      t.string   :target_type, limit: 60, null: false
    end

    add_index :references, %i[source_id source_type target_id target_type],
              name: :index_references_on_source_and_target, unique: true
    add_index :references, %i[source_id source_type], name: :index_references_on_source_id_and_source_type
  end
end
