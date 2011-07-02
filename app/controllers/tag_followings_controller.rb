class TagFollowingsController < ApplicationController
  before_filter :authenticate_user!

  # POST /tag_followings
  # POST /tag_followings.xml
  def create
    @tag = ActsAsTaggableOn::Tag.find_or_create_by_name(params[:name])
    @tag_following = current_user.tag_followings.new(:tag_id => @tag_id)

    respond_to do |format|
      if @tag_following.save
        format.html { redirect_to(tag_path(:name => params[:name]), :notice => "Successfully following: #{params[:name]}" ) }
        format.xml  { render :xml => @tag_following, :status => :created, :location => @tag_following }
      else
        render :nothing => true, :status => :unprocessable_entity
      end
    end
  end

  # DELETE /tag_followings/1
  # DELETE /tag_followings/1.xml
  def destroy
    @tag = ActsAsTaggableOn::Tag.find_by_name(params[:name])
    @tag_following = current_user.tag_followings.where(:tag_id => @tag.id).first
    if @tag_following && @tag_following.destroy
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 410
    end
  end
end
