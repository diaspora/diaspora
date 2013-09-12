class PostReporter < ActiveRecord::Base

  after_save :send_report_notification

  def send_report_notification
    Workers::Mail::PostReportWorker.perform_async
  end
end
