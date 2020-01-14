# frozen_string_literal: true

class AddTwoFactorBackupableToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :otp_backup_codes, :text
  end
end
