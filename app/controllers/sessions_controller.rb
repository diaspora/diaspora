#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class SessionsController < Devise::SessionsController

  after_filter :enqueue_update, :only => :create

  protected

  def enqueue_update
    begin
    if current_user
      current_user.services.each do |s|
        Resque.enqueue(Jobs::UpdateServiceUsers, s.id) if s.respond_to? :save_friends
      end
    end
    rescue
    end
  end
end
