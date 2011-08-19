class DiasporaDeviseMailer < DeviseMailer
  include NotifierHelper
  default :from => AppConfig[:smtp_sender_address]

end
