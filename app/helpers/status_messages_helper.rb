#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module StatusMessagesHelper
  def my_latest_message
    unless @latest_status_message.nil?
      return @latest_status_message.text
    else
      return I18n.t('status_messages.helper.no_message_to_display')
    end
  end
end
