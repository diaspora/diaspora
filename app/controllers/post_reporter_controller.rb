class PostReporterController < ApplicationController
  before_filter :authenticate_user!

  def index
    redirect_unless_admin
    @post_reporter = PostReporter.where(reviewed: false).all
  end

  def update
    redirect_unless_admin
    if PostReporter.exists?(post_id: params[:id])
      mark_as_reviewed
    end
    redirect_to :action => :index
  end

  def destroy
    redirect_unless_admin
    if Post.exists?(params[:id])
      delete_post
      mark_as_reviewed
    end
    redirect_to :action => :index
  end

  def create
    username = current_user.username
    unless PostReporter.where(post_id: params[:post_id]).exists?(user_id: username)
      post = PostReporter.new(
        :post_id => params[:post_id],
        :user_id => username,
        :text => params[:text])
      result = post.save
      status(( 200 if result ) || ( 422 if !result ))
    else
      status(409)
    end
  end

  private
    def delete_post id = params[:id]
      post = Post.find(id)
      post.destroy
      flash[:notice] = I18n.t 'post_reporter.status.destroyed'
    end

    def mark_as_reviewed id = params[:id]
      posts = PostReporter.where(post_id: id)
      posts.each do |post|
        post.update_attributes(reviewed: true)
      end
      flash[:notice] = I18n.t 'post_reporter.status.marked'
    end

    def status(code)
      if code == 200
        flash[:notice] = I18n.t 'post_reporter.status.created'
      else
        flash[:error] = I18n.t 'post_reporter.status.failed'
      end
      render :nothing => true, :status => code
    end
end
