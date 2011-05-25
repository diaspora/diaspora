#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ActivityStreams::PhotosController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token, :only => :create

  respond_to :json
  respond_to :html, :only => [:show, :destroy]

  def create
    @photo = ActivityStreams::Photo.from_activity(params[:activity])
    @photo.author = current_user.person
    @photo.public = true

    if @photo.save
      Rails.logger.info("event=create type=activitystreams_photo")

      current_user.add_to_streams(@photo, current_user.aspects)
      current_user.dispatch_post(@photo, :url => post_url(@photo))

      render :nothing => true, :status => 201
    else
      render :nothing => true, :status => 422
    end
  end

  def show
    @photo = current_user.find_visible_post_by_id(params[:id])
    respond_with @photo
  end

  def destroy
    @photo = current_user.posts.where(:id => params[:id]).first
    if @photo
      current_user.retract(@photo)
    end
    respond_with @photo
  end
end
