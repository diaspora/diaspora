# frozen_string_literal: true

namespace :generate do
  desc "Generates a key for encrypting 2fa tokens"
  task :twofa_key do
    path = Rails.root.join("config", "initializers", "twofa_encryption_key.rb")
    key = SecureRandom.hex(32)
    File.open(path, "w") do |f|
      f.write <<~CONF
        # frozen_string_literal: true

        # The 2fa encryption key is used to encrypt users' OTP tokens in the database.

        # You can regenerate this key by running `rake generate:twofa_key`

        # If you change this key after a user has set up 2fa
        # the users' tokens cannot be recovered
        # and they will not be able to log in again!

        Diaspora::Application.config.twofa_encryption_key = "#{key}"
      CONF
    end
  end
end
