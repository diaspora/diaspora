# frozen_string_literal: true

class RemoveInvalidUnconfirmedEmails < ActiveRecord::Migration[4.2]
  class User < ApplicationRecord
  end

  def up
    User.joins("INNER JOIN users as valid_user ON users.unconfirmed_email = valid_user.email")
        .where("users.id != valid_user.id").update_all(unconfirmed_email: nil, confirm_email_token: nil)
  end
end
