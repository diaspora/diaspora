#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module StatusMessagesHelper
  def my_latest_message
    unless @latest_status_message.nil?
      return @latest_status_message.message
    else
      return I18n.t('status_messages.helper.no_message_to_display')
    end
  end

  def make_links(message)
    # If there should be some kind of bb-style markup, email/diaspora highlighting, it could go here.
    
    # next line is important due to XSS! (h is rail's make_html_safe-function)
    message = h(message).html_safe
    message.gsub!(/( |^)(www\.[^ ]+\.[^ ])/, '\1http://\2');
    return message.gsub(/(http|ftp):\/\/([^ ]+)/, '<a target="_blank" href="\1://\2">\2</a>');
  end

end
