# frozen_string_literal: true

class DecryptTwoFactorSecret < ActiveRecord::Migration[5.1]
  class User < ApplicationRecord
  end

  def up
    add_column :users, :plain_otp_secret, :string

    key = twofa_encryption_key
    decrypt_existing_secrets(key) if key

    change_table :users, bulk: true do |t|
      t.remove :encrypted_otp_secret
      t.remove :encrypted_otp_secret_iv
      t.remove :encrypted_otp_secret_salt
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def twofa_encryption_key
    if AppConfig.heroku?
      ENV["TWOFA_ENCRYPTION_KEY"]
    else
      key_file = File.expand_path("../../config/initializers/twofa_encryption_key.rb", File.dirname(__FILE__))

      if File.exist? key_file
        require key_file
        File.delete(key_file)

        return Diaspora::Application.config.twofa_encryption_key
      end
    end
  end

  def decrypt_existing_secrets(key)
    User.where.not(encrypted_otp_secret: nil).each do |user|
      user.plain_otp_secret = Encryptor.decrypt(
        value: user.encrypted_otp_secret.unpack("m").first,
        key:   key,
        iv:    user.encrypted_otp_secret_iv.unpack("m").first,
        salt:  user.encrypted_otp_secret_salt.slice(1..-1).unpack("m").first
      )
      user.save!
    end
  end
end
