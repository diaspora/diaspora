# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Diaspora::Application.configure do
  config.action_mailer.perform_deliveries = AppConfig.mail.enable?

  unless Rails.env == 'test' || !AppConfig.mail.enable?
    if AppConfig.mail.method == "sendmail"
      config.action_mailer.delivery_method = :sendmail
      sendmail_settings = {
        location: AppConfig.mail.sendmail.location.get
      }
      sendmail_settings[:arguments] = "-i" if AppConfig.mail.sendmail.exim_fix?
      config.action_mailer.sendmail_settings = sendmail_settings
    elsif AppConfig.mail.method == "smtp"
      config.action_mailer.delivery_method = :smtp
      smtp_settings = {
        address:              AppConfig.mail.smtp.host.get,
        port:                 AppConfig.mail.smtp.port.to_i,
        domain:               AppConfig.mail.smtp.domain.get,
        enable_starttls_auto: false,
        openssl_verify_mode:  AppConfig.mail.smtp.openssl_verify_mode.get,
        ca_file:              AppConfig.environment.certificate_authorities.get
      }

      if AppConfig.mail.smtp.authentication != "none"
        smtp_settings.merge!({
          authentication:       AppConfig.mail.smtp.authentication.gsub('-', '_').to_sym,
          user_name:            AppConfig.mail.smtp.username.get,
          password:             AppConfig.mail.smtp.password.get,
          enable_starttls_auto: AppConfig.mail.smtp.starttls_auto?
        })
      end

      config.action_mailer.smtp_settings = smtp_settings
    else
      $stderr.puts "WARNING: Mailer turned on with unknown method #{AppConfig.mail.method}. Mail won't work."
    end
  end
end
