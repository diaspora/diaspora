class AuthorsController < ApplicationController
  before_filter :authenticate_user!
  
  def show
    @author= Author.where(:id => params[:id]).first
    @author_ostatus_posts = @author.ostatus_posts.sort(:created_at.desc)
  end


  def destroy
    current_user.unsubscribe_from_pubsub(params[:id])
    flash[:notice] = "unsubscribed person."
    redirect_to ostatus_path 
  end 
  
end
