class PeopleController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    unless params[:q]
      @people = current_user.friends.paginate :page => params[:page], :order => 'created_at DESC'
      render :index
    else
      @people = Person.search(params[:q])
      render :json => @people.to_json(:only => :_id)
    end
  end
  
  def show
    @person = current_user.visible_person_by_id(params[:id])
    @profile = @person.profile
    @posts = Post.find_all_by_person_id(@person.id).paginate :page => params[:page], :order => 'created_at DESC'
    @latest_status_message = StatusMessage.newest_for(@person)
    @post_count = @posts.count
  end
  
  def destroy
    current_user.unfriend(current_user.visible_person_by_id(params[:id]))
    flash[:notice] = "unfriended person."
    redirect_to people_url
  end
  
end
