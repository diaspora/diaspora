class TagFollowingsController < ApplicationController
  before_filter :authenticate_user!

  # POST /tag_followings
  # POST /tag_followings.xml
  def create
    @tag = ActsAsTaggableOn::Tag.find_or_create_by_name(params[:name])
    @tag_following = current_user.tag_followings.new(:tag_id => @tag.id)

    if @tag_following.save
      redirect_to(tag_path(:name => params[:name]), :notice => "Successfully following: #{params[:name]}" ) 
    else
      render :nothing => true, :status => 406
    end
  end

  # DELETE /tag_followings/1
  # DELETE /tag_followings/1.xml
  def destroy
    @tag = ActsAsTaggableOn::Tag.find_by_name(params[:name])
    @tag_following = current_user.tag_followings.where(:tag_id => @tag.id).first
    if @tag_following && @tag_following.destroy
      redirect_to(tag_path(:name => params[:name]), :notice => "Successfully stopped following: #{params[:name]}" ) 
    else
      render :nothing => true, :status => 410
    end
  end
end
