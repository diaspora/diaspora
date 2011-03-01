class Notifications::NewRequest < Notification
  def mail_job
    Job::MailRequestReceived
  end
  def translation_key
    'new_request'
  end
end
