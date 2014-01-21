class ReportController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_unless_admin, :except => [:create]

  def index
    @report = Report.where(reviewed: false).all
  end

  def update
    if Report.where(post_type: params[:type]).exists?(post_id: params[:id])
      mark_as_reviewed
    end
    redirect_to :action => :index and return
  end

  def destroy
    if (params[:type].eql? "post")
      if Post.exists?(params[:id])
        delete_post
      end
    elsif (params[:type].eql? "comment")
      if Comment.exists?(params[:id])
        delete_comment
      end
    end
    redirect_to :action => :index and return
  end

  def create
    code = 400
    username = current_user.username
    post = Report.new(
      :post_id => params[:id],
      :post_type => params[:type],
      :user_id => username,
      :text => params[:text])
    unless Report.where("post_id = ? AND post_type = ?", params[:id], params[:type]).exists?(user_id: username)
      result = post.save
      code = 200 if result
    end
    render :nothing => true, :status => code
  end

  private
    def delete_post
      post = Post.find(params[:id])
      current_user.retract(post)
      mark_as_reviewed
      flash[:notice] = I18n.t 'report.status.destroyed'
    end

    def delete_comment
      comment = Comment.find(params[:id])
      #current_user.retract(comment)
      comment.destroy
      mark_as_reviewed
      flash[:notice] = I18n.t 'report.status.destroyed'
    end

    def mark_as_reviewed
      posts = Report.where("post_id = ? AND post_type = ?", params[:id], params[:type])
      posts.each do |post|
        post.update_attributes(reviewed: true)
      end
      flash[:notice] = I18n.t 'report.status.marked'
    end
end
