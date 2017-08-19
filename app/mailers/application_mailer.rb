class ApplicationMailer < ActionMailer::Base
  default from: "\"#{AppConfig.settings.pod_name}\" <#{AppConfig.mail.sender_address}>"
end
