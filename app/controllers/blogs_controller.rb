class BlogsController < ApplicationController
  before_filter :authenticate_user!


  def index
    @blogs = Blog.sort(:created_at.desc).all
  end
  
  def show
    @blog = Blog.find(params[:id])
  end
  
  def new
    @blog = Blog.new
  end
  
  def create
    @blog = Blog.new(params[:blog])
    @blog.person = current_user
    if @blog.save
      flash[:notice] = "Successfully created blog."
      redirect_to @blog
    else
      render :action => 'new'
    end
  end
  
  def edit
    @blog = Blog.where(:id => params[:id]).first
  end
  
  def update
    @blog = Blog.where(:id => params[:id]).first
    if @blog.update_attributes(params[:blog])
      flash[:notice] = "Successfully updated blog."
      redirect_to @blog
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @blog = Blog.where(:id => params[:id]).first
    @blog.destroy
    flash[:notice] = "Successfully destroyed blog."
    redirect_to blogs_url
  end
end
