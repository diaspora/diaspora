require 'devise'

module DeviseInvitable
  autoload :Inviter, 'devise_invitable/inviter'
end

require 'devise_invitable/mailer'
require 'devise_invitable/routes'
require 'devise_invitable/schema'
require 'devise_invitable/controllers/url_helpers'
require 'devise_invitable/controllers/helpers'
require 'devise_invitable/rails'

module Devise
  # Public: Validity period of the invitation token (default: 0). If 
  # invite_for is 0 or nil, the invitation will never expire.
  # Set invite_for in the Devise configuration file (in config/initializers/devise.rb).
  #
  #   config.invite_for = 2.weeks # => The invitation token will be valid 2 weeks
  mattr_accessor :invite_for
  @@invite_for = 0

  # Public: Flag that force a record to be valid before being actually invited 
  # (default: false).
  #
  # Examples (in config/initializers/devise.rb)
  #
  #   config.validate_on_invite = true
  mattr_accessor :validate_on_invite
  @@validate_on_invite = false

  # Public: number of invitations the user is allowed to send
  #
  # Examples (in config/initializers/devise.rb)
  #
  #   config.invitation_limit = nil
  mattr_accessor :invitation_limit
  @@invitation_limit = nil
  
  # Public: The key to be used to check existing users when sending an invitation
  #
  # Examples (in config/initializers/devise.rb)
  #
  #   config.invite_key = :email
  mattr_accessor :invite_key
  @@invite_key = :email
end

Devise.add_module :invitable, :controller => :invitations, :model => 'devise_invitable/model', :route => :invitation
