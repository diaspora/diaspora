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
    name_normalized = ActsAsTaggableOn::Tag.normalize(params['name'])

    if name_normalized.nil? || name_normalized.empty?
      head :forbidden
    else
      @tag = ActsAsTaggableOn::Tag.find_or_create_by(name: name_normalized)
      @tag_following = current_user.tag_followings.new(:tag_id => @tag.id)

      if @tag_following.save
        render :json => @tag.to_json, :status => 201
      else
        head :forbidden
      end
    end
  end

  # DELETE /tag_followings/1
  # DELETE /tag_followings/1.xml
  def destroy
    tag_following = current_user.tag_followings.find_by_tag_id( params['id'] )

    if tag_following && tag_following.destroy
      respond_to do |format|
        format.any(:js, :json) { head :no_content }
      end
    else
      respond_to do |format|
        format.any(:js, :json) { head :forbidden }
      end
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
end
