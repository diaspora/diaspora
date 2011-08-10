class Notifications::AlsoCommented < Notification
  def mail_job
    Job::Mail::AlsoCommented
  end
  def popup_translation_key
    'notifications.also_commented'
  end
end
