require 'devise'

module Devise
  # Time interval where the invitation token is valid.
  mattr_accessor :invite_for
  @@invite_for = 0
end

Devise.add_module :invitable, :controller => :invitations, :model => 'devise_invitable/model', :route => :invitation

require 'devise_invitable/mailer'
require 'devise_invitable/routes'
require 'devise_invitable/schema'
require 'devise_invitable/controllers/url_helpers'
require 'devise_invitable/controllers/helpers'
require 'devise_invitable/rails'
