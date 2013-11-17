#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class SessionsController < Devise::SessionsController

  layout "application", :only => [:new]
  before_action -> { @css_framework = :bootstrap }, only: [:new]

end
