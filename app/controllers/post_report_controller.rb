class PostReportController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_unless_admin, :except => [:create]

  def index
    @post_report = PostReport.where(reviewed: false).all
  end

  def update
    if PostReport.exists?(post_id: params[:id])
      mark_as_reviewed
    end
    redirect_to :action => :index and return
  end

  def destroy
    if Post.exists?(params[:id])
      delete_post
      mark_as_reviewed
    end
    redirect_to :action => :index and return
  end

  def create
    username = current_user.username
    unless PostReport.where(post_id: params[:post_id]).exists?(user_id: username)
      post = PostReport.new(
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
    def delete_post
      post = Post.find(params[:id])
      current_user.retract(post)
      flash[:notice] = I18n.t 'post_report.status.destroyed'
    end

    def mark_as_reviewed id = params[:id]
      posts = PostReport.where(post_id: id)
      posts.each do |post|
        post.update_attributes(reviewed: true)
      end
      flash[:notice] = I18n.t 'post_report.status.marked'
    end

    def status(code)
      if code == 200
        flash[:notice] = I18n.t 'post_report.status.created'
      else
        flash[:error] = I18n.t 'post_report.status.failed'
      end
      render :nothing => true, :status => code
    end
end
