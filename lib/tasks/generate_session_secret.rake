namespace :generate do
  desc 'Generates a Session Secret Token'
  task :secret_token do

  path = Rails.root.join('config', 'initializers', 'secret_token.rb')
  secret = SecureRandom.hex(40)
  File.open(path, 'w') do |f|
    f.write <<"EOF"
# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Diaspora::Application.config.secret_key_base = '#{secret}'
EOF

end

  end
end
