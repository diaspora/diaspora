module StatusMessagesHelper

  def my_latest_message
    message = @latest_status_message
    unless message.nil?
      return message.message + "   -   " + how_long_ago(message)
    else
      return "No message to display."
    end
  end

end
