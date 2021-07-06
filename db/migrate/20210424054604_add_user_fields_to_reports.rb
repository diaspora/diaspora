# frozen_string_literal: true

class AddUserFieldsToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :originator_diaspora_handle, :string, index: true

    Report.find_each do |report|
      # get originator author from item before item gets deleted
      unless report.reported_author.nil?
        report.originator_diaspora_handle = report.reported_author.diaspora_handle
        report.save(validate: false, touch: false)
      end
      if report.item.nil?
        report.action = "Deleted"
        report.save(validate: false, touch: false)
      end
    end
  end
end
