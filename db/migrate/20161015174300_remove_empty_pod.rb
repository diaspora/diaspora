# frozen_string_literal: true

class RemoveEmptyPod < ActiveRecord::Migration[4.2]
  def up
    Pod.where("host IS NULL").delete_all

    change_column :pods, :host, :string, null: false
  end

  def down
    change_column :pods, :host, :string, null: true
  end
end
