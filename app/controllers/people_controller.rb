class PeopleController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @people = Person.friends.paginate :page => params[:page], :order => 'created_at DESC'
  end
  
  def show
    @person= Person.where(:id => params[:id]).first
    @person_profile = @person.profile
    @person_posts = Post.where(:person_id => @person.id).sort(:created_at.desc)
  end
  
  def destroy
    @person = Person.where(:id => params[:id]).first
    @person.destroy
    flash[:notice] = "Successfully destroyed person."
    redirect_to people_url
  end
  
end
