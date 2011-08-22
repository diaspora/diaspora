class DiasporaDeviseMailer < Devise::Mailer
  default :from => AppConfig[:smtp_sender_address]

  def self.mailer_name
    "devise/mailer"
  end
end
