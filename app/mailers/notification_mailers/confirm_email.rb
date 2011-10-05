module NotificationMailers
  class ConfirmEmail < NotificationMailers::Base
    def set_headers
      @headers[:to] = "\"#{recipient_name}\" <#{@recipient.unconfirmed_email}>"
      @headers[:subject] = I18n.t('notifier.confirm_email.subject', :unconfirmed_email => @recipient.unconfirmed_email)
    end
  end
end