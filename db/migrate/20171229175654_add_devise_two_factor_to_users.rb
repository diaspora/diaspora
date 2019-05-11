# frozen_string_literal: true

class AddDeviseTwoFactorToUsers < ActiveRecord::Migration[5.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :encrypted_otp_secret
      t.string :encrypted_otp_secret_iv
      t.string :encrypted_otp_secret_salt
      t.integer :consumed_timestep
      t.boolean :otp_required_for_login
    end
  end
end
