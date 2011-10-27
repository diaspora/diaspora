#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ActivityStreams::PhotosController < ApplicationController
  class AuthenticationFilter
    def initialize(scope = nil)
      @scope = scope
    end

    def filter(controller, &block)
      if controller.params[:auth_token]
        if controller.current_user
          yield
        else
          controller.fail!
        end
      else
        controller.request.env['oauth2'].authenticate_request! :scope => @scope do |*args|
          controller.sign_in controller.request.env['oauth2'].resource_owner
          block.call(*args)
        end
      end
    end
  end

  around_filter AuthenticationFilter.new, :only => :create
  skip_before_filter :verify_authenticity_token, :only => :create

  respond_to :json
  respond_to :html, :only => [:show]

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
    @photo = current_user.find_visible_shareable_by_id(Photo, params[:id])
    respond_with @photo
  end

  def fail!
    render :nothing => true, :status => 401
  end
end
