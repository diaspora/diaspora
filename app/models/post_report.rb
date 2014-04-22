class PostReport < ActiveRecord::Base
  validates :user, presence: true
  validates :post, presence: true

  belongs_to :user
  belongs_to :post

  after_create :send_report_notification

  def send_report_notification
    Workers::Mail::PostReportWorker.perform_async
  end
end
