# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class TagFollowingsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json
  respond_to :html, only: [:manage]

  # POST /tag_followings
  # POST /tag_followings.xml
  def create
    tag = tag_followings_service.create(params["name"])
    render json: tag.to_json, status: :created
  rescue TagFollowingService::DuplicateTag
    render json: tag_followings_service.find(params["name"]), status: :created
  rescue StandardError
    head :forbidden
  end

  # DELETE /tag_followings/1
  # DELETE /tag_followings/1.xml
  def destroy
    tag_followings_service.destroy(params["id"])

    respond_to do |format|
      format.any(:js, :json) { head :no_content }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.any(:js, :json) { head :forbidden }
    end
  end

  def index
    respond_to do |format|
      format.json{ render(:json => tags.to_json, :status => 200) }
    end
  end

  def manage
    redirect_to followed_tags_stream_path unless request.format == :mobile
    gon.preloads[:tagFollowings] = tags
  end

  private

  def tag_followings_service
    TagFollowingService.new(current_user)
  end
end
