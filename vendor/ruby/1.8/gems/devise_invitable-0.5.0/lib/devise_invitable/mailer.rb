module DeviseInvitable
  module Mailer
    
    # Deliver an invitation email
    def invitation_instructions(record)
      setup_mail(record, :invitation_instructions)
    end
    
    def invitation(record)
      ActiveSupport::Deprecation.warn('invitation has been renamed to invitation_instructions')
      invitation_instructions(record)
    end
  end
end
