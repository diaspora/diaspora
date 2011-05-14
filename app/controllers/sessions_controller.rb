#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class SessionsController < Devise::SessionsController

  after_filter :enqueue_update, :only => :create

  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    redirect_loc = redirect_location(resource_name, resource)
    respond_with resource, :location => redirect_loc do |format|
      format.mobile { redirect_to root_path }
    end
  end

  protected
  def enqueue_update
    if current_user
      current_user.services.each{|s|
        Resque.enqueue(Job::UpdateServiceUsers, s.id) if s.respond_to? :save_friends
      }
    end
  end
end
