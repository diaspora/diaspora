# frozen_string_literal: true

class RemoveStringColumnFromPpid < ActiveRecord::Migration[5.1]
  def change
    remove_column :ppid, :string, :string, limit: 32
  end
end
