# frozen_string_literal: true

class AddReportingColumnsToReport < ActiveRecord::Migration[6.1]
  def change
    add_column :reports, :reported_author_id, :integer
    add_column :reports, :action, :string
  end
end
