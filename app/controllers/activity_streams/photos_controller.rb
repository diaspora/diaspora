#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ActivityStreams::PhotosController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_unless_admin
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def create
    @photo = ActivityStreams::Photo.from_activity(params[:activity])
    @photo.author = current_user.person
    @photo.public = true
    
    if @photo.save
      Rails.logger.info("event=create type=activitystreams_photo")

      current_user.add_to_streams(@photo, current_user.aspects)
      current_user.dispatch_post(@photo, :url => post_url(@photo))

      render :nothing => true, :status => 201
    end
  end
end
