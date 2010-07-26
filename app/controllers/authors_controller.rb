class AuthorsController < ApplicationController
  before_filter :authenticate_user!
  
  def show
    @author= Author.where(:id => params[:id]).first
    @author_ostatus_posts = @author.ostatus_posts.paginate :page => params[:page], :order => 'created_at DESC'
  end


  def destroy
    current_user.unsubscribe_from_pubsub(params[:id])
    flash[:notice] = "unsubscribed person."
    redirect_to ostatus_path 
  end 
  
end
