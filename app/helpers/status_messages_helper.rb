#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


module StatusMessagesHelper
  def my_latest_message
    unless @latest_status_message.nil?
      return @latest_status_message.message
    else
      return "No message to display."
    end
  end
end
