# frozen_string_literal: true

class ResetPasswordWorker < BaseWorker
  sidekiq_options queue: :urgent

  def perform(user_id)
    User.find(user_id).send_reset_password_instructions!
  end
end
