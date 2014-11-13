#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class SessionsController < Devise::SessionsController

  layout ->(c) { request.format == :mobile ? "application" : "with_header_with_footer" }, :only => [:new]
  use_bootstrap_for :new

  after_filter :reset_authentication_token, :only => [:create]
  before_filter :reset_authentication_token, :only => [:destroy]

  def reset_authentication_token
    current_user.reset_authentication_token!
  end
end
