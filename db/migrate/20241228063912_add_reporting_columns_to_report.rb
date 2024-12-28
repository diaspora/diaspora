# frozen_string_literal: true

class AddReportingColumnsToReport < ActiveRecord::Migration[6.1]
  def change
    add_reference :reports, :reporting_user, null: true, foreign_key: {to_table: :users}
    add_column :reports, :action, :string
  end
end
