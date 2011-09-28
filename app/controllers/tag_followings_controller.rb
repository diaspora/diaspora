require File.join(Rails.root, '/lib/tag_stream')
class TagFollowingsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @stream = TagStream.new(current_user, :max_time => params[:max_time])

    if params[:only_posts]
      render :partial => 'shared/stream', :locals => {:posts => @stream.posts}
    else
      render 'aspects/index'
    end
  end

  # POST /tag_followings
  # POST /tag_followings.xml
  def create
    @tag = ActsAsTaggableOn::Tag.find_or_create_by_name(params[:name])
    @tag_following = current_user.tag_followings.new(:tag_id => @tag.id)

    if @tag_following.save
      flash[:notice] = I18n.t('tag_followings.create.success', :name => params[:name])
    else
      flash[:error] = I18n.t('tag_followings.create.failure', :name => params[:name])
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
        format.all{}
        format.js{ render 'tags/update' }
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
end
