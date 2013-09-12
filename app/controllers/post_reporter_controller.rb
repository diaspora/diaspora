class PostReporterController < ApplicationController
  before_filter :authenticate_user!

  def index
    redirect_unless_admin
    @post_reporter = PostReporter.where("reviewed = 0").all
  end

  def update
    redirect_unless_admin
    if PostReporter.exists?(id: params[:id])
      post = PostReporter.find(params[:id])
      post.update_attributes(:reviewed => 1)
    end
    redirect_to action: 'index'
  end

  def destroy
    redirect_unless_admin
    if Post.exists?(id: params[:id])
      post = Post.find(params[:id])
      post.destroy
    end
    redirect_to action: 'index'
  end

  def create
    username = @current_user.username
    if !PostReporter.where("post_id = #{params[:post_id]}").exists?(user_id: username)
      post = PostReporter.new(
	:post_id => params[:post_id],
	:user_id => username,
	:text => params[:text])
      result = post.save
      status(( 200 if result ) || ( 500 if !result ))
    else
      status(409)
    end
  end

  private
    def status(code)
      render :nothing => true, :status => code
    end
end
