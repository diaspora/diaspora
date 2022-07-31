# frozen_string_literal: true

module NotificationMailers
  class Base
    include Diaspora::Logging

    attr_accessor :recipient, :sender

    delegate :unconfirmed_email, :confirm_email_token,
             :first_name, to: :recipient, prefix: true
    delegate :first_name, :name, :sender, to: :sender, prefix: true

    def initialize(recipient_id, sender_id=nil, *args)
      @headers = {}
      @recipient = User.find(recipient_id)
      @sender = Person.find(sender_id) if sender_id.present?

      log_mail(recipient_id, sender_id, self.class.to_s.underscore)

      with_recipient_locale do
        set_headers(*args)
      end
    end

    def headers
      default_headers.merge(@headers)
    end

    def name_and_address(name, email)
      address = Mail::Address.new Addressable::IDNA.to_ascii(email)
      address.display_name = name
      address.format
    end

    private

    def default_headers
      from_name = AppConfig.settings.pod_name
      from_name += " (#{@sender.profile.full_name.empty? ? @sender.username : @sender.name})" if @sender.present?

      {
        from:          name_and_address(from_name, AppConfig.mail.sender_address),
        to:            name_and_address(@recipient.name, @recipient.email),
        template_name: self.class.name.demodulize.underscore
      }
    end

    def with_recipient_locale(&block)
      I18n.with_locale(@recipient.language, &block)
    end

    def log_mail(recipient_id, sender_id, type)
      log_string = "event=mail mail_type=#{type} recipient_id=#{recipient_id} sender_id=#{sender_id} " \
                   " recipient_handle=#{@recipient.diaspora_handle}"
      log_string = "#{log_string} sender_handle=#{@sender.diaspora_handle}" if sender_id.present?

      logger.info log_string
    end
  end
end
