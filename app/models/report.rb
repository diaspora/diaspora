class Report < ActiveRecord::Base
  validates :user_id, presence: true
  validates :post_id, presence: true
  validates :post_type, presence: true

  belongs_to :user
  belongs_to :post

  has_many :reports  

  after_create :send_report_notification

  def send_report_notification
    Workers::Mail::ReportWorker.perform_async(self.post_type, self.post_id)
  end
end
