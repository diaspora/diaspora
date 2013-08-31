#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class TagFollowingsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  # POST /tag_followings
  # POST /tag_followings.xml
  def create
    name_normalized = ActsAsTaggableOn::Tag.normalize(params['name'])

    if name_normalized.nil? || name_normalized.empty?
      render :nothing => true, :status => 403
    else
      @tag = ActsAsTaggableOn::Tag.find_or_create_by(name: name_normalized)
      @tag_following = current_user.tag_followings.new(:tag_id => @tag.id)

      if @tag_following.save
        render :json => @tag.to_json, :status => 201
      else
        render :nothing => true, :status => 403
      end
    end
  end

  # DELETE /tag_followings/1
  # DELETE /tag_followings/1.xml
  def destroy
    tag_following = current_user.tag_followings.find_by_tag_id( params['id'] )

    if tag_following && tag_following.destroy
      respond_to do |format|
        format.any(:js, :json) { render :nothing => true, :status => 204 }
      end
    else
      respond_to do |format|
        format.any(:js, :json) {render :nothing => true, :status => 403}
      end
    end
  end

  def index
    respond_to do |format|
      format.json{ render(:json => tags.to_json, :status => 200) }
    end
  end
end
