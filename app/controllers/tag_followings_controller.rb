#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class TagFollowingsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json

  # POST /tag_followings
  # POST /tag_followings.xml
  def create
    name_normalized = ActsAsTaggableOn::Tag.normalize(params['name'])

    if name_normalized.nil? || name_normalized.empty?
      flash[:error] = I18n.t('tag_followings.create.none')
    else
      @tag = ActsAsTaggableOn::Tag.find_or_create_by_name(name_normalized)
      @tag_following = current_user.tag_followings.new(:tag_id => @tag.id)

      if @tag_following.save
        flash[:notice] = I18n.t('tag_followings.create.success', :name => name_normalized)
      else
        flash[:error] = I18n.t('tag_followings.create.failure', :name => name_normalized)
      end
    end

    redirect_to :back
  end

  # DELETE /tag_followings/1
  # DELETE /tag_followings/1.xml
  def destroy
    @tag = ActsAsTaggableOn::Tag.find_by_name(params[:name])
    @tag_following = current_user.tag_followings.where(:tag_id => @tag.id).first
    if @tag_following && @tag_following.destroy
      @tag_unfollowed = true
    else
      @tag_unfollowed = false
    end

    if params[:remote]
      respond_to do |format|
        format.all {}
        format.js { render 'tags/update' }
      end
    else
      if @tag_unfollowed
        flash[:notice] = I18n.t('tag_followings.destroy.success', :name => params[:name])
      else
        flash[:error] = I18n.t('tag_followings.destroy.failure', :name => params[:name])
      end
      redirect_to tag_path(:name => params[:name])
    end
  end

  def create_multiple
    if params[:tags].present?
      params[:tags].split(",").each do |name|
        name_normalized = ActsAsTaggableOn::Tag.normalize(name)
        @tag = ActsAsTaggableOn::Tag.find_or_create_by_name(name_normalized)
        @tag_following = current_user.tag_followings.create(:tag_id => @tag.id)
      end
    end
    redirect_to multi_stream_path
  end
end
