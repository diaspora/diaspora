module NotificationMailers
  TRUNCATION_LEN = 70

  class Base
    attr_accessor :recipient, :sender
    
    delegate :unconfirmed_email, :confirm_email_token,
             :first_name, to: :recipient, prefix: true
    delegate :first_name, :name, :sender, to: :sender, prefix: true

    def initialize(recipient_id, sender_id=nil, *args)
      @headers = {}
      @recipient = User.find_by_id(recipient_id)
      @sender = Person.find_by_id(sender_id) if sender_id.present?

      log_mail(recipient_id, sender_id, self.class.to_s.underscore)

      with_recipient_locale do
        set_headers(*args)
      end
    end

    def headers
      default_headers.merge(@headers)
    end

    def name_and_address(name, email)
      address = Mail::Address.new email
      address.display_name = name
      address.format
    end

    private
    def default_headers
      headers = {
        :from => AppConfig[:smtp_sender_address],
        :host => "#{AppConfig[:pod_uri]}",
        :to => name_and_address(@recipient.name, @recipient.email)
      }

      headers[:from] = "\"#{@sender.name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>" if @sender.present?

      headers
    end

    def with_recipient_locale(&block)
      I18n.with_locale(@recipient.language, &block)
    end

    def log_mail(recipient_id, sender_id, type)
      log_string = "event=mail mail_type=#{type} recipient_id=#{recipient_id} sender_id=#{sender_id}"
      if @recipient && @sender
        log_string << "models_found=true sender_handle=#{@sender.diaspora_handle} recipient_handle=#{@recipient.diaspora_handle}"
      else
        log_string << "models_found=false"
      end

      Rails.logger.info(log_string)
    end
  end
end
