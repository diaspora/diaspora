class UpdateReportItemTypes < ActiveRecord::Migration
  def change
    Report.all.each do |report|
      report.update_attribute :item_type, report[:item_type].capitalize
    end
  end
end
