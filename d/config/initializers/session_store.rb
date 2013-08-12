# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_d_session',
  :secret      => '59d91e33d1c87a64fcd596ec1ba3ad1dc6025846d6c731bb39db9a0e21f874396005a97e3ed82e8b4d2888707ec7124fae5509dfd8d53a40ae8e9772d50f1146'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
