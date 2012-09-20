module NotificationMailers
  class PrivateMessage < NotificationMailers::Base
    attr_accessor :message, :conversation, :participants

    def set_headers(message_id)
      @message  = Message.find_by_id(message_id)
      @conversation = @message.conversation
      @participants = @conversation.participants

      @headers[:from] = "\"#{@message.author_name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>"
      @headers[:subject] = @conversation.subject.strip
      @headers[:subject] = "Re: #{@headers[:subject]}" if @conversation.messages.size > 1
    end
  end
end
