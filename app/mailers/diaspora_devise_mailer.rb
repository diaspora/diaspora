# frozen_string_literal: true

class DiasporaDeviseMailer < Devise::Mailer
  default from: "\"#{AppConfig.settings.pod_name}\" <#{AppConfig.mail.sender_address}>"

  def self.mailer_name
    "devise/mailer"
  end
end
