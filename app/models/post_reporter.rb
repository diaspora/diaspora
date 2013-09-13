class PostReporter < ActiveRecord::Base
  validates :user_id, presence: true
  validates :post_id, presence: true

  belongs_to :user
  belongs_to :post

  has_many :post_reporters  

  after_save :send_report_notification

  def send_report_notification
    Workers::Mail::PostReportWorker.perform_async
  end
end
