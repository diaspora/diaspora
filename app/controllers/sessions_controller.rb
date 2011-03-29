#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class SessionsController < Devise::SessionsController

  after_filter :enqueue_update, :only => :create
  protected
  def enqueue_update
    if current_user
      current_user.services.each{|s|
        Resque.enqueue(Job::UpdateServiceUsers, s.id) if s.respond_to? :save_friends
      }
    end
  end

end
