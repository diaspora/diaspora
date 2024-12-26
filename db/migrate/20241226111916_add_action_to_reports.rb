# frozen_string_literal: true

class AddActionToReports < ActiveRecord::Migration[6.1]
  def change
    add_column :reports, :action, :string
  end
end
