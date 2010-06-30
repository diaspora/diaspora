class FriendsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @friends = Friend.paginate :page => params[:page], :order => 'created_at DESC'
  end
  
  def show
    @friend = Friend.where(:id => params[:id]).first
    @friend_profile = @friend.profile
    @friend_posts = Post.where(:person_id => @friend.id).sort(:created_at.desc)
  end
  
  def destroy
    @friend = Friend.where(:id => params[:id]).first
    @friend.destroy
    flash[:notice] = "Successfully destroyed friend."
    redirect_to friends_url
  end
  
  def new
    @friend = Friend.new
    @profile = Profile.new
  end
  
  def create
   
    puts params.inspect
    @friend = Friend.new(params[:friend])


    if @friend.save
      flash[:notice] = "Successfully created friend."
      redirect_to @friend
    else
      render :action => 'new'
    end
  end
end
