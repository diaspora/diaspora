class DiasporaDeviseMailer < Devise::Mailer
  include NotifierHelper
  default :from => AppConfig[:smtp_sender_address]

end
