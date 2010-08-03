class BlogsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @blogs = Blog.paginate :page => params[:page], :order => 'created_at DESC'
    
    respond_to do |format|
      format.html 
      format.atom {render :xml => Diaspora::OStatus::generate(:current_url => request.url, :objects => @blogs)}
    end
  

  end
  
  def show
    @blog = Blog.find(params[:id])
  end
  
  def new
    @blog = Blog.new
  end
  
  def create
    @blog = current_user.post(:blog, params[:blog])

    if @blog.created_at
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
    redirect_to root_url
  end
end
