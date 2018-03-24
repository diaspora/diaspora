# frozen_string_literal: true

module NotificationMailers
  class PrivateMessage < NotificationMailers::Base
    attr_accessor :message, :conversation, :participants

    def set_headers(message_id)
      @message = Message.find_by_id(message_id)
      @conversation = @message.conversation
      @participants = @conversation.participants

      @headers[:subject] = I18n.t("notifier.private_message.subject")
      @headers[:in_reply_to] = @headers[:references] = "<#{@conversation.guid}@#{AppConfig.pod_uri.host}>"
    end
  end
end
