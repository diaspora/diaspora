#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  def edit
    @person = current_user.person
    @aspect  = :person_edit
    @profile = @person.profile
  end

  def update
     # upload and set new profile photo
    params[:profile] ||= {}
    params[:profile][:searchable] ||= false
    params[:profile][:photo] = Photo.where(:person_id => current_user.person.id,
                                           :id => params[:photo_id]).first if params[:photo_id]

    if current_user.update_profile params[:profile]
      flash[:notice] = I18n.t 'profiles.update.updated'
    else
      flash[:error] = I18n.t 'profiles.update.failed'
    end

    if params[:getting_started]
      redirect_to getting_started_path(:step => params[:getting_started].to_i+1)
    else
      redirect_to edit_profile_path
    end
 
  end
end
