class PeopleController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    unless params[:q]
      @people = current_user.friends.paginate :page => params[:page], :order => 'created_at DESC'
      render :index
    else
      @people = Person.search_for_friends(params[:q])
      render :json => @people.to_json(:only => :_id)
    end
  end
  
  def show
    @person= current_user.friend_by_id(params[:id])
  
    @person_profile = @person.profile
    @person_posts = Post.where(:person_id => @person.id).paginate :page => params[:page], :order => 'created_at DESC'
    @latest_status_message = StatusMessage.newest_for(@person)
    @post_count = @person_posts.count
  end
  
  def destroy
    current_user.unfriend(current_user.friend_by_id(params[:id]))
    flash[:notice] = "unfriended person."
    redirect_to people_url
  end
  
end
