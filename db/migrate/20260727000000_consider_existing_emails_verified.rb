# frozen_string_literal: true

# Clean all unfinished email verification so no user is blocked
class ConsiderExistingEmailsVerified < ActiveRecord::Migration[6.1]
  def up
    execute "UPDATE users SET confirm_email_token = NULL, unconfirmed_email = NULL " \
            "WHERE confirm_email_token IS NOT NULL OR unconfirmed_email IS NOT NULL"
  end
end
