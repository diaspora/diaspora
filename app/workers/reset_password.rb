module Workers
  class ResetPassword < Base
    sidekiq_options queue: :mail

    def perform(user_id)
      User.find(user_id).send_reset_password_instructions!
    end
  end
end
