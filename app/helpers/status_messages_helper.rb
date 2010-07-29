module StatusMessagesHelper

  def my_latest_message
    unless @latest_status_message.nil?
      return @latest_status_message.message
    else
      return "No message to display."
    end
  end
  
  

end
