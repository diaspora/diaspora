class DiasporaDeviseMailer < Devise::Mailer
  default :from => AppConfig.mail.sender_address

  def self.mailer_name
    "devise/mailer"
  end
end
