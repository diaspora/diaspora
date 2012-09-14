#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# Use this hook to configure devise mailer, warden hooks and so forth. The first
# four configuration values can also be set straight in your models.

class ActionController::Responder
  def to_mobile
    default_render
  rescue ActionView::MissingTemplate => e
    navigation_behavior(e)
  end
end

Devise.setup do |config|
  # Configure the e-mail address which will be shown in DeviseMailer.
  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default), :mongoid
  # (bson_ext recommended) and :data_mapper (experimental).
  require 'devise/orm/active_record'

  #mail setup
  if AppConfig[:smtp_sender_address]
    config.mailer_sender = AppConfig[:smtp_sender_address]
  else
    unless Rails.env == 'test'
      Rails.logger.warn("No smtp sender address set, mail may fail.")
      puts "WARNING: No smtp sender address set, mail may fail."
    end
    config.mailer_sender = "please-change-me@config-initializers-devise.com"
  end

  # Configure the class responsible to send e-mails.
  config.mailer = "DiasporaDeviseMailer"

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating an user. By default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating an user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  config.authentication_keys = [:username]

  # Tell if authentication through request.params is enabled. True by default.
  # config.params_authenticatable = true

  # Tell if authentication through HTTP Basic Auth is enabled. True by default.
  # config.http_authenticatable = true

  # The realm used in Http Basic Authentication
  # config.http_authentication_realm = "Application"

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 10. If
  # using other encryptors, it sets how many times you want the password re-encrypted.
  config.stretches = Rails.env.test? ? 1 : 10

  # Setup a pepper to generate the encrypted password.
  config.pepper = "065eb8798b181ff0ea2c5c16aee0ff8b70e04e2ee6bd6e08b49da46924223e39127d5335e466207d42bf2a045c12be5f90e92012a4f05f7fc6d9f3c875f4c95b"
  
  config.reset_password_within = 2.days

  # ==> Configuration for :invitable
  # Time interval where the invitation token is valid (default: 0).
  # If invite_for is 0 or nil, the invitation will never expire.
  # config.invite_for = 2.weeks

  # ==> Configuration for :confirmable
  # The time you want to give your user to confirm his account. During this time
  # he will be able to access your application without confirming. Default is nil.
  # When confirm_within is zero, the user won't be able to sign in without confirming.
  # You can use this to let your user access some features of your application
  # without confirming the account, but blocking it after a certain period
  # (ie 2 days).
  # config.allow_unconfirmed_access_for = 2.days

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  # config.remember_for = 2.weeks
  
  # ==> Configuration for :validatable
  # Range for password length
  # config.password_length = 6..20

  # Regex to use to validate the email address
  # config.email_regexp = /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again.
  config.timeout_in = 1.day

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  # config.lock_strategy = :failed_attempts

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  # config.unlock_strategy = :both

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  # config.maximum_attempts = 20

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  # config.unlock_in = 1.hour

  # ==> Configuration for :token_authenticatable
  # Defines name of the authentication token params key
  config.token_authentication_key = :auth_token
  config.skip_session_storage << :token_auth

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "sessions/users/new". It's turned off by default because it's slower if you
  # are using only default views.
  # config.scoped_views = true

  # By default, devise detects the role accessed based on the url. So whenever
  # accessing "/users/sign_in", it knows you are accessing an User. This makes
  # routes as "/sign_in" not possible, unless you tell Devise to use the default
  # scope, setting true below.
  # Note that devise does not generate default routes. You also have to
  # specify them in config/routes.rb

  # Configure the default scope used by Devise. By default it's the first devise
  # role declared in your routes.
  config.default_scope = :user

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists. Default is [:html]
  # config.navigational_formats = [:html, :iphone]
  config.navigational_formats = [:"*/*", "*/*", :html, :mobile]

  # Looks up user emails ignoring case
  # for forgot password, sign up, sign in, etc
  config.case_insensitive_keys = [:email]

  # ==> Warden configuration
  # If you want to use other strategies, that are not (yet) supported by Devise,
  # you can configure them inside the config.warden block. The example below
  # allows you to setup OAuth, using http://github.com/roman/warden_oauth
  #
  # config.warden do |manager|
  #   manager.oauth(:twitter) do |twitter|
  #     twitter.consumer_secret = <YOUR CONSUMER SECRET>
  #     twitter.consumer_key  = <YOUR CONSUMER KEY>
  #     twitter.options :site => 'http://twitter.com'
  #   end
  #   manager.default_strategies(:scope => :user).unshift :twitter_oauth
  # end
end

