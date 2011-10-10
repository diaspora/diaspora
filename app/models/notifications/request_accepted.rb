#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Notifications::RequestAccepted < Notification
  def mail_job
    Jobs::Mailers::RequestAcceptance
  end
  def popup_translation_key
    'notifications.request_accepted'
  end
end
