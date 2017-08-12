class UpdateReportItemTypes < ActiveRecord::Migration[4.2]
  def change
    Report.all.each do |report|
      report.update_attribute :item_type, report[:item_type].capitalize
    end
  end
end
