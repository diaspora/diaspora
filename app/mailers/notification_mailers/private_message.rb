module NotificationMailers
  class PrivateMessage < NotificationMailers::Base
    attr_accessor :message, :conversation, :participants, :text_owner

    def set_headers(message_id)
      @message = Message.find_by_id(message_id)
      @conversation = @message.conversation
      @participants = @conversation.participants
      @text_owner = @message.author.owner

      @headers[:from] = "\"#{@message.author.name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>"
      @headers[:subject] = @text_owner.user_preferences.exists?(:email_type => 'silent') ? "#{I18n.t('notifier.private_message.silenced_subject', :name => "#{@sender.name}")}" : @conversation.subject.strip
      @headers[:subject] = "Re: #{@headers[:subject]}" if @conversation.messages.size > 1
    end
  end
end
